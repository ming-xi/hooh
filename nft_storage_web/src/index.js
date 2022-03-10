import { NFTStorage } from "./nft.storage.js"
document.addEventListener('DOMContentLoaded', async () => {
    log("DOMContentLoaded  start");
    const NFT_STORAGE_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDIzZkYwOTE1MjRDNDc5YURBNmE5NWU2M2Q4OUZlMTU1NDgwNTlDMzQiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTY0NjI3NTc2ODgzNSwibmFtZSI6ImFwcCJ9.l3RD6Ab4L5v0ZVJuXsZmwDARkePYwhwK7Ekj-a2GcZg'
    const client = new NFTStorage({ token: NFT_STORAGE_TOKEN })
    window.client = client
    log("DOMContentLoaded  end");
    sendNodeReadyMessage("");
})

function log(message) {

    try {
        logHandler.postMessage(message);
    } catch (e) {
        console.log(message)
    }
}

function sendNodeReadyMessage(message) {
    onNodeReady.postMessage(message);
}

function sendUploadCompleteMessage(message) {
    onUploadComplete.postMessage(message);
}

function dataURLtoFileBytes(dataurl) {
    var arr = dataurl.split(','),
        mime = arr[0].match(/:(.*?);/)[1],
        bstr = atob(arr[1]),
        n = bstr.length,
        u8arr = new Uint8Array(n);

    while (n--) {
        u8arr[n] = bstr.charCodeAt(n);
    }
    return u8arr;
}

async function addBase64File(taskId, base64String, delay) {
    log("addBase64File start")
    let cid = await addFile(dataURLtoFileBytes(base64String));
    setTimeout(function () {
        sendUploadCompleteMessage(JSON.stringify({
            task_id: taskId,
            cid: cid.toString()
        }));
    }, delay);
}
async function addBase64FileTest( base64String) {
    let cid = await addFile(dataURLtoFileBytes(base64String));
  console.log(cid);
}

async function addFile(fileBytes) {
    // const {cid} = await node.add(file)
    // log('successfully stored', cid.toString())
    // await pinFile(cid)
    // return cid;
    const imageFile = new File([ fileBytes ], 'nft.png', { type: 'image/png' })

    const cid = await window.client.storeBlob(imageFile)
    log('successfully stored', cid.toString())
    return cid
    // const imageFile = new File([ fileBytes ], 'nft.png', { type: 'image/png' })
    // const metadata = await client.store({
    //     name: 'My sweet NFT',
    //     description: 'Just try to funge it. You can\'t do it.',
    //     image: imageFile
    // })
    // log('successfully stored', metadata.toString())
    // return metadata

}

async function catFile(cid) {
    for await (const data of
        node.cat(cid)) {
        // node.cat('QmRV7njbZs1iCP3g7HYgwqDnS2Pd4cL2yKGpasNodHe8dk')) {
        // log(data.toString())
        log(data)
    }
}

async function pinFile(cid) {
    let cid2 = await node.pin.add(cid)
    log("pinned file:" + cid2)
}
// export {log}
window.nft= {log,addBase64File,addBase64FileTest}