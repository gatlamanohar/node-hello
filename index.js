const express = require('express');
const app = express();
const port = 3000; // You can choose any available port

app.get('/', (req, res) => {
  res.send('Hello, Team!! Application successfully deployed through Terraform.');
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
