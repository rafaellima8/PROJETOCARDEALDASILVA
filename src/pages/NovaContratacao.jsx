import React, { useState, useEffect } from "react";
import Papa from "papaparse";

export default function NovaContratacao() {
  const [csvData, setCsvData] = useState([]);
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [selected, setSelected] = useState("");
  const [qtd, setQtd] = useState(1);
  const [estimativa, setEstimativa] = useState(null);

  // Lê o CSV na pasta public quando carrega a página
  useEffect(() => {
    Papa.parse("/sinapi_ba.csv", {
      header: true,
      download: true,
      complete: (results) => setCsvData(results.data),
    });
  }, []);

  // Autocomplete dinâmico
  useEffect(() => {
    if (query.length < 2) {
      setSuggestions([]);
      return;
    }
    setSuggestions(
      csvData
        .filter(item =>
          item.Descricao && item.Descricao.toLowerCase().includes(query.toLowerCase())
        )
        .slice(0, 5)
    );
  }, [query, csvData]);

  function handleSelect(obj) {
    setSelected(obj);
    setQuery(obj.Descricao);
    setSuggestions([]);
    setEstimativa(null);
  }

  function calcularEstimativa() {
    if (selected && selected.Valor) {
      const valor = parseFloat(selected.Valor.replace(",", "."));
      setEstimativa(valor * qtd);
    }
  }

  return (
    <div style={{ padding: 32 }}>
      <h2>Nova Contratação</h2>
      <div style={{ maxWidth: 500 }}>
        <label>Objeto a ser licitado:</label>
        <input
          type="text"
          value={query}
          onChange={e => {
            setQuery(e.target.value);
            setSelected("");
            setEstimativa(null);
          }}
          style={{ width: "100%", padding: 8, margin: "8px 0" }}
        />
        {suggestions.length > 0 && (
          <ul style={{ border: "1px solid #ddd", padding: 0, margin: 0, listStyle: "none", background: "#fff" }}>
            {suggestions.map(item => (
              <li key={item.Codigo}
                  style={{ padding: 6, cursor: "pointer" }}
                  onClick={() => handleSelect(item)}
              >
                {item.Descricao}
              </li>
            ))}
          </ul>
        )}
        <label>Quantidade:</label>
        <input
          type="number"
          value={qtd}
          min={1}
          style={{ width: "100%", padding: 8, margin: "8px 0" }}
          onChange={e => {
            setQtd(e.target.value);
            setEstimativa(null);
          }}
        />
        <button onClick={calcularEstimativa} disabled={!selected || !qtd}>Calcular estimativa</button>
        {estimativa && (
          <div style={{ marginTop: 12, padding: 12, background: "#e7fbe7", borderRadius: 6 }}>
            <b>Estimativa total:</b> R$ {estimativa.toLocaleString("pt-BR", {minimumFractionDigits: 2})}
            <br />
            <b>Objeto:</b> {selected.Descricao}
            <br />
            <b>Justificativa:</b> {selected.Justificativa || "Sugestão automática para o objeto selecionado."}
          </div>
        )}
      </div>
    </div>
  );
}