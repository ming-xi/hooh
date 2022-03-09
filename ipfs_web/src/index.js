document.addEventListener('DOMContentLoaded', async () => {
    console.log("DOMContentLoaded  start");
    // const insertAfter = (referenceNode, newNode) => {
    //   referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
    // }

    const node = await Ipfs.create({repo: 'ipfs-' + Math.random()})
    window.node = node

    const status = node.isOnline() ? 'online' : 'offline'
    const id = await node.id()

    console.log(`Node status: ${status} id: ${id}`)

    // const statusDOM = document.getElementById('status')
    // statusDOM.innerHTML = `Node status: ${status}`

    // const newDiv = document.createElement("div");
    // newDiv.id = "node"
    // const newContent = document.createTextNode(`ID: ${id.id}`);
    // newDiv.appendChild(newContent);

    // insertAfter(statusDOM, newDiv);
    console.log("DOMContentLoaded  end");
    sendNodeReadyMessage("");
    // You can write more code here to use it. Use methods like
    // node.add, node.get. See the API docs here:
    // https://github.com/ipfs/js-ipfs/tree/master/packages/interface-ipfs-core
})

function sendNodeReadyMessage(message) {
    onNodeReady.postMessage(message);
}

function sendUploadCompleteMessage(message) {
    onUploadComplete.postMessage(message);
}

function dataURLtoFile(dataurl) {
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
    console.log("addBase64File start")
    let cid = await addFile(dataURLtoFile(base64String));
    setTimeout(function () {
        sendUploadCompleteMessage(JSON.stringify({
            task_id: taskId,
            cid: cid.toString()
        }));
    }, delay);
    // sendUploadCompleteMessage(cid.toString());
}

async function addFile(file) {

    // const {cid} = await node.add('Hello world!')
    const {cid} = await node.add(file)
    // console.log('successfully stored',JSON.stringify(cid))
    console.log('successfully stored', cid.toString())
    await pinFile(cid)
    return cid;
}

async function catFile(cid) {
    for await (const data of
        node.cat(cid)) {
        // node.cat('QmRV7njbZs1iCP3g7HYgwqDnS2Pd4cL2yKGpasNodHe8dk')) {
        // console.log(data.toString())
        console.log(data)
    }
}

async function pinFile(cid) {
    let cid2 = await node.pin.add(cid)
    console.log("pinned file:" + cid2)
}
