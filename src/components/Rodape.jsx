import React from "react";

export default function Rodape() {
  return (
    <div style={{
      marginTop: "auto",
      background: "linear-gradient(0deg,#b2df8a 0%, #fafafa 100%)",
      borderRadius: "0 0 24px 24px",
      minHeight: 65,
      display: "flex",
      alignItems: "center",
      justifyContent: "flex-end",
    }}>
      <img
        src="/brasao-cardeal.png"
        alt="Brasão Cardeal da Silva"
        style={{ height: 52, marginRight: 30, marginTop: 5 }}
      />
      <img
        src="/prefeitura-cardeal.png"
        alt="Prefeitura Cardeal da Silva"
        style={{ height: 36, marginRight: 30, marginTop: 5 }}
      />
    </div>
  );
}