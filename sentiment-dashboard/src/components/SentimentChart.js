// components/SentimentChart.js
import { Bar } from 'react-chartjs-2';

export default function SentimentChart({ sentimentData }) {
  if (!sentimentData || !sentimentData.SentimentScore) return null;

  const scores = sentimentData.SentimentScore.M;

  const data = {
    labels: ['Positive', 'Negative', 'Neutral', 'Mixed'],
    datasets: [
      {
        label: 'Confidence',
        data: [
          parseFloat(scores.Positive.N),
          parseFloat(scores.Negative.N),
          parseFloat(scores.Neutral.N),
          parseFloat(scores.Mixed.N)
        ],
        backgroundColor: ['green', 'red', 'gray', 'orange']
      }
    ]
  };

  return <Bar data={data} />;
}
