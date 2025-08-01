import React, { useEffect, useState } from "react";
import Papa from "papaparse";

export default function AnalisePreditiva() {
  const [data, setData] = useState([]);
  const [media, setMedia] = useState(null);

  useEffect(() => {
    Papa.parse("/sinapi_ba.csv", {
      header: true,
      download: true,
      complete: (results) => {
        setData(results.data);
        const valores = results.data
          .map(i => parseFloat(i.Valor?.replace(",", ".")))
          .filter(v => !isNaN(v));
        setMedia(valores.reduce((a, b) => a + b, 0) / (valores.length || 1));
      }
    });
  }, []);

  return (
    <div style={{ padding: 32 }}>
      <h2>Análise Preditiva</h2>
      <div>
        <b>Média dos valores do CSV:</b> {media ? media.toLocaleString("pt-BR", {minimumFractionDigits:2}) : "..."}
      </div>
      <div style={{ marginTop: 18 }}>
        <b>Exemplos de itens analisados:</b>
        <ul>
          {data.slice(0, 10).map((item, i) => (
            <li key={i}>{item.Descricao} - R$ {item.Valor}</li>
          ))}
        </ul>
      </div>
      {/* Integração real com API Python/Prophet pode ser feita aqui */}
    </div>
  );
}