function sendNodeReadyMessage(e){onNodeReady.postMessage(e)}function sendUploadCompleteMessage(e){onUploadComplete.postMessage(e)}function dataURLtoFile(e){for(var o=e.split(","),n=(o[0].match(/:(.*?);/)[1],atob(o[1])),t=n.length,a=new Uint8Array(t);t--;)a[t]=n.charCodeAt(t);return a}async function addBase64File(e,o,n){console.log("addBase64File start");let t=await addFile(dataURLtoFile(o));setTimeout((function(){sendUploadCompleteMessage(JSON.stringify({task_id:e,cid:t.toString()}))}),n)}async function addFile(e){const{cid:o}=await node.add(e);return console.log("successfully stored",o.toString()),await pinFile(o),o}async function catFile(e){for await(const o of node.cat(e))console.log(o)}async function pinFile(e){let o=await node.pin.add(e);console.log("pinned file:"+o)}document.addEventListener("DOMContentLoaded",(async()=>{console.log("DOMContentLoaded  start");const e=await Ipfs.create({repo:"ipfs-"+Math.random()});window.node=e;const o=e.isOnline()?"online":"offline",n=await e.id();console.log(`Node status: ${o} id: ${n}`),console.log("DOMContentLoaded  end"),sendNodeReadyMessage("")}));
//# sourceMappingURL=index.67426c87.js.map
