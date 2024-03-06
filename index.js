const express = require('express');
const app = express();
const port = 3000; // You can choose any available port
 
app.get('/', (req, res) => {
  res.send('Hello, Express! app development');
});
 
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

