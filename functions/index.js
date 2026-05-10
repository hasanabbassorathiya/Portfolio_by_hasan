const { onRequest } = require('firebase-functions/v2/https');
const { defineString } = require('firebase-functions/params');
const axios = require('axios');
const cors = require('cors')({ origin: true });

const tursoUrl = defineString('TURSO_URL');
const tursoToken = defineString('TURSO_TOKEN');

exports.tursoProxy = onRequest(async (req, res) => {
  cors(req, res, async () => {
    try {
      const response = await axios.post(
        tursoUrl.value(),
        req.body,
        {
          headers: {
            'Authorization': `Bearer ${tursoToken.value()}`,
            'Content-Type': 'application/json',
          }
        }
      );
      res.status(200).send(response.data);
    } catch (error) {
      res.status(500).send(error.message);
    }
  });
});
