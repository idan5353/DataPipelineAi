"use client";

import FileUpload from '@/components/FileUpload';
import SentimentChart from '@/components/SentimentChart';
import { useState } from 'react';

export default function Home() {
  const [sentimentData, setSentimentData] = useState(null);

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-4">Serverless Sentiment Analyzer</h1>
      <FileUpload />
      {sentimentData && <SentimentChart sentimentData={sentimentData} />}
    </div>
  );
}
