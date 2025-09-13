"use client";
import { useState } from "react";
import axios from "axios";
import SentimentChart from "@/components/SentimentChart";

export default function FileUpload() {
  const [file, setFile] = useState(null);
  const [sentimentData, setSentimentData] = useState(null);
  const [entities, setEntities] = useState([]);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleUpload = async () => {
    if (!file) return;

    setLoading(true);
    const reader = new FileReader();
    reader.readAsDataURL(file);

    reader.onload = async () => {
      const base64Content = reader.result.split(",")[1];

      try {
        const API_URL = process.env.NEXT_PUBLIC_API_URL;
        if (!API_URL) throw new Error("API URL is missing");

        const res = await axios.post(
          API_URL,
          { file_name: file.name, file_content: base64Content },
          { headers: { "Content-Type": "application/json" } }
        );

        const sentiment = res.data?.sentiment || {};
        setSentimentData(sentiment?.SentimentScore || null);
        setEntities(res.data?.entities || []);
        setError(null);
      } catch (err) {
        setError(err.response?.data?.error || err.message);
      } finally {
        setLoading(false);
      }
    };

    reader.onerror = () => {
      setError("File reading failed");
      setLoading(false);
    };
  };

  return (
    <div className="max-w-3xl mx-auto mt-10 p-6 bg-white rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold mb-4 text-center text-gray-800">
        Upload & Analyze File
      </h2>

      <div className="flex flex-col md:flex-row items-center gap-4 mb-4">
        <input
          type="file"
          className="border border-gray-300 p-2 rounded w-full md:w-auto"
          onChange={(e) => e.target.files && setFile(e.target.files[0])}
        />
        <button
          onClick={handleUpload}
          disabled={loading || !file}
          className={`px-6 py-2 rounded font-semibold text-white transition-colors ${
            loading || !file
              ? "bg-gray-400 cursor-not-allowed"
              : "bg-blue-600 hover:bg-blue-700"
          }`}
        >
          {loading ? "Analyzing..." : "Upload & Analyze"}
        </button>
      </div>

      {error && (
        <p className="text-red-500 mt-2 text-center font-medium">{error}</p>
      )}

      {sentimentData && (
        <div className="mt-6">
          <h3 className="text-xl font-semibold mb-2 text-gray-700">
            Sentiment Analysis
          </h3>
          <SentimentChart sentimentData={sentimentData} />
        </div>
      )}

      {entities.length > 0 && (
        <div className="mt-6">
          <h3 className="text-xl font-semibold mb-2 text-gray-700">
            Entities Detected
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            {entities.map((e, idx) => (
              <div
                key={idx}
                className="bg-blue-100 text-blue-800 px-3 py-2 rounded shadow-sm hover:shadow-md transition-shadow"
              >
                <span className="font-medium">{e.Text}</span>{" "}
                <span className="text-sm text-gray-600">({e.Type})</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
