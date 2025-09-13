// pages/index.js
import FileUpload from '../components/FileUpload';
import SentimentChart from '../components/SentimentChart';
import { useState } from 'react';
import axios from 'axios';

export default function Home() {
  const [sentiment, setSentiment] = useState(null);

  const fetchResult = async (file_name) => {
    const res = await axios.get(`https://<your-api-gateway-url>/result?file=${file_name}`);
    setSentiment(res.data.sentiment);
  };

  return (
    <div>
      <h1>Serverless Sentiment Analyzer</h1>
      <FileUpload />
      {sentiment && <SentimentChart sentimentData={sentiment.SentimentScore} />}
    </div>
  );
}
