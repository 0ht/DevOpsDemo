import React, { useState } from 'react';
import axios from 'axios';

import './App.css';
import { Container, TextField, Button, Typography, Box } from '@mui/material';
import { ThemeProvider, createTheme } from '@mui/material/styles';

const theme = createTheme();
const App: React.FC = () => {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [message, setMessage] = useState('');
  const [searchTitle, setSearchTitle] = useState('');
  const [retrievedContent, setRetrievedContent] = useState('');

  const saveNote = async () => {
    try {
      const response = await axios.post('http://localhost:3000/notes', { title, content });
      setMessage(response.data);
    } catch (error) {
      setMessage('Error saving note');
    }
  };

  const searchNote = async () => {
    try {
      const response = await axios.get(`http://localhost:3000/notes/${searchTitle}`);
      setRetrievedContent(response.data);
    } catch (error) {
      setRetrievedContent('Error retrieving note');
    }
  };

  return (
    <ThemeProvider theme={theme}>
      <Container maxWidth="sm" style={{ marginTop: '20px' }}>
        <Typography variant="h4" gutterBottom>
          Note Taking App
        </Typography>

        <Box mb={2}>
          <TextField
            fullWidth
            label="Title"
            variant="outlined"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
        </Box>

        <Box mb={2}>
          <TextField
            fullWidth
            label="Content"
            variant="outlined"
            multiline
            rows={4}
            value={content}
            onChange={(e) => setContent(e.target.value)}
          />
        </Box>

        <Button variant="contained" style={{ backgroundColor: 'black', color: 'white' }} onClick={saveNote} fullWidth>
          Save Note
        </Button>

        {message && (
          <Typography color="secondary" style={{ marginTop: '10px' }}>
            {message}
          </Typography>
        )}

        <Box mt={4}>
          <Typography variant="h6">Search Note</Typography>
          <TextField
            fullWidth
            label="Enter title to search"
            variant="outlined"
            value={searchTitle}
            onChange={(e) => setSearchTitle(e.target.value)}
            style={{ marginBottom: '10px' }}
          />
          <Button variant="contained" color="secondary" onClick={searchNote} fullWidth>
            Search
          </Button>
          {retrievedContent && (
            <Typography style={{ marginTop: '10px' }}>{retrievedContent}</Typography>
          )}
        </Box>
      </Container>
    </ThemeProvider>
  );
};

export default App;
