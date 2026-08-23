/// <reference types="@citizenfx/server" />
/// <reference types="image-js" />

const imagejs = require('image-js');
const fs = require('fs');
const path = require('path');

const resName = GetCurrentResourceName();
const mainSavePath = `resources/${resName}/images`;
const config = JSON.parse(LoadResourceFile(GetCurrentResourceName(), "config.json"));

try { if (!fs.existsSync(mainSavePath)) fs.mkdirSync(mainSavePath, { recursive: true }); } catch(e){}

async function processAndSave(pngBuffer, fullFilePath, despill) {
	let image = await imagejs.Image.load(pngBuffer);
	if (!image.alpha || image.channels < 4) {
		const w = image.width, h = image.height;
		const rgba = new Uint8Array(w * h * 4);
		for (let i = 0, j = 0; i < w * h; i++, j += 3) {
			rgba[i*4]=image.data[j]; rgba[i*4+1]=image.data[j+1]; rgba[i*4+2]=image.data[j+2]; rgba[i*4+3]=255;
		}
		image = new imagejs.Image(w, h, rgba, { kind: 'RGBA' });
	}
	for (let x = 0; x < image.width; x++) {
		for (let y = 0; y < image.height; y++) {
			const p = image.getPixelXY(x, y);
			if (p[1] > 50 && p[1] > p[0] * 1.2 && p[1] > p[2] * 1.2) {
				image.setPixelXY(x, y, [255, 255, 255, 0]);
			} else if (despill) {
				// Green-spill removal for hair: the ped's hair is semi-transparent,
				// so kept pixels are a blend of hair + green screen and read green.
				// Clamp the green channel to what red/blue support (standard despill),
				// which neutralises the green cast without desaturating real colours.
				const cap = Math.max(p[0], p[2]);
				if (p[1] > cap) {
					image.setPixelXY(x, y, [p[0], cap, p[2], p[3]]);
				}
			}
		}
	}
	const W = image.width, H = image.height;
	const visited = new Uint8Array(W * H);
	let bestSize = 0, minX = W, maxX = -1, minY = H, maxY = -1;
	const isOpaque = (x, y) => { if (x<0||y<0||x>=W||y>=H) return false; if (visited[y*W+x]) return false; return image.getPixelXY(x,y)[3]>0; };
	for (let sy = 0; sy < H; sy++) {
		for (let sx = 0; sx < W; sx++) {
			if (visited[sy*W+sx]) continue;
			if (image.getPixelXY(sx,sy)[3]===0) { visited[sy*W+sx]=1; continue; }
			let size=0,bMinX=sx,bMaxX=sx,bMinY=sy,bMaxY=sy;
			const q=[sx,sy]; visited[sy*W+sx]=1;
			while(q.length){const cy=q.pop(),cx=q.pop();size++;if(cx<bMinX)bMinX=cx;if(cx>bMaxX)bMaxX=cx;if(cy<bMinY)bMinY=cy;if(cy>bMaxY)bMaxY=cy;if(isOpaque(cx+1,cy)){visited[cy*W+(cx+1)]=1;q.push(cx+1,cy);}if(isOpaque(cx-1,cy)){visited[cy*W+(cx-1)]=1;q.push(cx-1,cy);}if(isOpaque(cx,cy+1)){visited[(cy+1)*W+cx]=1;q.push(cx,cy+1);}if(isOpaque(cx,cy-1)){visited[(cy-1)*W+cx]=1;q.push(cx,cy-1);}}
			if (size > bestSize) { bestSize=size; minX=bMinX; maxX=bMaxX; minY=bMinY; maxY=bMaxY; }
		}
	}
	if (maxX>=minX && maxY>=minY) {
		const c = image.crop({x:minX,y:minY,width:maxX-minX+1,height:maxY-minY+1});
		image.data=c.data; image.width=c.width; image.height=c.height;
	}
	await image.save(fullFilePath);
}


// Hair is clothing component 2 (`<gender>_2_<drawable>`); props are `<gender>_prop_…`
// and every other component has a different number, so this only matches hair.
function isHairFile(filename) {
	return /^(male|female)_2_\d/.test(String(filename));
}

// Receive base64 capture from client's Lua bridge via TriggerLatentServerEvent
onNet('orb-greenscreen:saveCapture', (filename, type, dataUrl) => {
	console.log(`[orb-greenscreen] Received: ${filename}, data: ${dataUrl ? String(dataUrl).length : 0} chars`);

	const savePath = path.join(mainSavePath, type);
	try { if (!fs.existsSync(savePath)) fs.mkdirSync(savePath, { recursive: true }); } catch(e){}
	const fullFilePath = path.join(savePath, `${filename}.png`);

	if (!dataUrl) { console.error(`[orb-greenscreen] No data for ${filename}`); return; }

	const str = String(dataUrl);
	const base64 = str.replace(/^data:image\/\w+;base64,/, '');
	const buffer = Buffer.from(base64, 'base64');
	if (buffer.length === 0) { console.error(`[orb-greenscreen] Empty buffer for ${filename}`); return; }

	processAndSave(buffer, fullFilePath, isHairFile(filename))
		.then(() => console.log(`[orb-greenscreen] Saved: ${filename}.png`))
		.catch(err => { console.error(`[orb-greenscreen] Failed: ${filename}:`, err.message); try{fs.unlinkSync(fullFilePath);}catch(_){} });
});

console.log('[orb-greenscreen] Ready (screencapture mode)');
