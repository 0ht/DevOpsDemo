require("dotenv").config({ path: ".env.local" }); // Explicitly specify the .env.local file
const express = require('express');
const { BlobServiceClient } = require('@azure/storage-blob');
const app = express();
const port = 3000;
const cors = require('cors');
app.use(cors());

// Middleware for parsing JSON
app.use(express.json());

// Azure Blob Storage setup
const connectionString = process.env.AZURE_STORAGE_CONNECTION_STRING;

if (!connectionString) {
    throw new Error("AZURE_STORAGE_CONNECTION_STRING is not defined. Please check your .env.local file.");
}

const blobServiceClient = BlobServiceClient.fromConnectionString(connectionString);
const containerName = 'notes';

// Create a container if it doesn't exist
async function createContainer() {
    const containerClient = blobServiceClient.getContainerClient(containerName);
    const exists = await containerClient.exists();
    if (!exists) {
        await containerClient.create();
        console.log(`Container ${containerName} created.`);
    }
}
createContainer();

// Save a note
app.post('/notes', async (req, res) => {
    const { title, content } = req.body;
    if (!title || !content) {
        return res.status(400).send('Title and content are required.');
    }

    const blobName = `${title}.txt`;
    const containerClient = blobServiceClient.getContainerClient(containerName);
    const blockBlobClient = containerClient.getBlockBlobClient(blobName);

    try {
        console.log('Uploading to Blob Storage:', blobName);
        await blockBlobClient.upload(content, Buffer.byteLength(content));
        res.status(201).send('Note saved successfully.');
    } catch (error) {
        console.error('Error saving note:', error.message);
        res.status(500).send('Error saving note.');
    }
});

// Get a note by title
app.get('/notes/:title', async (req, res) => {
    const { title } = req.params;
    const blobName = `${title}.txt`;
    const containerClient = blobServiceClient.getContainerClient(containerName);
    const blockBlobClient = containerClient.getBlockBlobClient(blobName);

    try {
        const downloadBlockBlobResponse = await blockBlobClient.download(0);
        const downloaded = await streamToString(downloadBlockBlobResponse.readableStreamBody);
        res.status(200).send(downloaded);
    } catch (error) {
        console.error('Error retrieving note:', error);
        res.status(404).send('Note not found.');
    }
});

// Helper function to convert stream to string
async function streamToString(readableStream) {
    return new Promise((resolve, reject) => {
        const chunks = [];
        readableStream.on('data', (data) => {
            chunks.push(data.toString());
        });
        readableStream.on('end', () => {
            resolve(chunks.join(''));
        });
        readableStream.on('error', reject);
    });
}

// Start the server
app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
