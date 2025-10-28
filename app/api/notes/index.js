const { BlobServiceClient } = require('@azure/storage-blob');
const { DefaultAzureCredential } = require('@azure/identity');

const containerName = 'notes';

async function getBlobServiceClient() {
    const connStr = process.env.AZURE_STORAGE_CONNECTION_STRING;
    if (connStr) {
        return BlobServiceClient.fromConnectionString(connStr);
    }

    // Expect AZURE_STORAGE_ACCOUNT_URL like https://<account>.blob.core.windows.net
    const accountUrl = process.env.AZURE_STORAGE_ACCOUNT_URL;
    if (!accountUrl) {
        throw new Error('Missing AZURE_STORAGE_CONNECTION_STRING and AZURE_STORAGE_ACCOUNT_URL');
    }

    const credential = new DefaultAzureCredential();
    return new BlobServiceClient(accountUrl, credential);
}

async function streamToString(readable) {
    return new Promise((resolve, reject) => {
        const chunks = [];
        readable.on('data', (d) => chunks.push(d.toString()));
        readable.on('end', () => resolve(chunks.join('')));
        readable.on('error', reject);
    });
}

module.exports = async function (context, req) {
    try {
        const blobServiceClient = await getBlobServiceClient();
        const containerClient = blobServiceClient.getContainerClient(containerName);
        const exists = await containerClient.exists();
        if (!exists) {
            await containerClient.create();
            context.log(`Created container ${containerName}`);
        }

        if (req.method === 'POST') {
            const { title, content } = req.body || {};
            if (!title || !content) {
                context.res = { status: 400, body: 'title and content are required' };
                return;
            }

            const safeTitle = encodeURIComponent(title);
            const blobName = `${safeTitle}.txt`;
            const blockBlobClient = containerClient.getBlockBlobClient(blobName);
            await blockBlobClient.uploadData(Buffer.from(content, 'utf8'), {
                blobHTTPHeaders: { blobContentType: 'text/plain; charset=utf-8' }
            });
            context.res = { status: 201, body: 'Note saved' };
            return;
        }

        // GET
        // title may come from route params or query
        const title = (req.params && req.params.title) || req.query.title;
        if (!title) {
            context.res = { status: 400, body: 'title is required' };
            return;
        }

        const encodedName = `${encodeURIComponent(title)}.txt`;
        const rawName = `${title}.txt`;
        const candidates = [encodedName, rawName];

        for (const blobName of candidates) {
            try {
                const blockBlobClient = containerClient.getBlockBlobClient(blobName);
                const downloadResp = await blockBlobClient.download(0);
                const downloaded = await streamToString(downloadResp.readableStreamBody);
                context.res = { status: 200, body: downloaded };
                return;
            } catch (err) {
                // continue to next candidate
            }
        }

        context.res = { status: 404, body: 'Note not found' };
    } catch (err) {
        context.log.error('API error', err && err.message ? err.message : err);
        context.res = { status: 500, body: err && err.message ? err.message : String(err) };
    }
};
