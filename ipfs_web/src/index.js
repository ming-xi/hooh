document.addEventListener('DOMContentLoaded', async () => {
    log("DOMContentLoaded  start");
    // const insertAfter = (referenceNode, newNode) => {
    //   referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
    // }

    const node = await Ipfs.create({
        repo: 'ipfs-' + Math.random(),
        // config: {
        //     Bootstrap: [
        //         "/dns4/ams-1.bootstrap.libp2p.io/tcp/443/wss/ipfs/QmSoLer265NRgSp2LA3dPaeykiS1J6DifTC88f5uVQKNAd",
        //         "/dns4/sfo-1.bootstrap.libp2p.io/tcp/443/wss/ipfs/QmSoLju6m7xTh3DuokvT3886QRYqxAzb1kShaanJgW36yx",
        //         "/dns4/lon-1.bootstrap.libp2p.io/tcp/443/wss/ipfs/QmSoLMeWqB7YGVLJN3pNLQpmmEk35v6wYtsMGLzSr5QBU3",
        //         "/dns4/sfo-2.bootstrap.libp2p.io/tcp/443/wss/ipfs/QmSoLnSGccFuZQJzRadHn95W2CrSFmZuTdDWP8HXaHca9z",
        //         "/dns4/sfo-3.bootstrap.libp2p.io/tcp/443/wss/ipfs/QmSoLPppuBtQSGwKDZT2M73ULpjvfd3aZ6ha4oFGL1KrGM",
        //         "/dns4/sgp-1.bootstrap.libp2p.io/tcp/443/wss/ipfs/QmSoLSafTMBsPKadTEgaXctDQVcqN88CNLHXMkTNwMKPnu",
        //         "/dns4/nyc-1.bootstrap.libp2p.io/tcp/443/wss/ipfs/QmSoLueR4xBeUbY9WZ9xGUUxunbKWcrNFTDAadQJmocnWm",
        //         "/dns4/nyc-2.bootstrap.libp2p.io/tcp/443/wss/ipfs/QmSoLV4Bbm51jM9C4gDYZQ9Cy3U6aXMJDAbzgu2fzaDs64"
        //     ],
        // },
    })
    window.node = node
    const status = node.isOnline() ? 'online' : 'offline'
    const id = await node.id()

    node.swarm.peers()
        .then(a => log(JSON.stringify(a)))
    log(`Node status: ${status} id: ${JSON.stringify(id)}`)

    // const statusDOM = document.getElementById('status')
    // statusDOM.innerHTML = `Node status: ${status}`

    // const newDiv = document.createElement("div");
    // newDiv.id = "node"
    // const newContent = document.createTextNode(`ID: ${id.id}`);
    // newDiv.appendChild(newContent);

    // insertAfter(statusDOM, newDiv);
    log("DOMContentLoaded  end");
    sendNodeReadyMessage("");
    // You can write more code here to use it. Use methods like
    // node.add, node.get. See the API docs here:
    // https://github.com/ipfs/js-ipfs/tree/master/packages/interface-ipfs-core
})

function log(message) {
    logHandler.postMessage(message);
}

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
    log("addBase64File start")
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
    // log('successfully stored',JSON.stringify(cid))
    log('successfully stored', cid.toString())
    await pinFile(cid)
    return cid;
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
