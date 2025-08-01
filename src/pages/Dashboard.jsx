import React, { useEffect, useRef } from "react";
import Chart from "chart.js/auto";
import Papa from "papaparse";

// Exemplo: mostra gráfico da soma dos valores de cada categoria no CSV
export default function Dashboard() {
  const chartRef = useRef(null);

  useEffect(() => {
    Papa.parse("/sinapi_ba.csv", {
      header: true,
      download: true,
      complete: (results) => {
        const data = results.data;
        const categorias = {};
        data.forEach(item => {
          if (item.Categoria && item.Valor) {
            const val = parseFloat(item.Valor.replace(",", "."));
            categorias[item.Categoria] = (categorias[item.Categoria] || 0) + (isNaN(val) ? 0 : val);
          }
        });
        const ctx = chartRef.current.getContext("2d");
        new Chart(ctx, {
          type: "bar",
          data: {
            labels: Object.keys(categorias),
            datasets: [{
              label: "Valor total por categoria",
              data: Object.values(categorias),
              backgroundColor: "#3d5fc5"
            }]
          }
        });
      }
    });
  }, []);

  return (
    <div style={{ padding: 32 }}>
      <h2>Dashboard</h2>
      <canvas ref={chartRef} width={700} height={300}></canvas>
    </div>
  );
}