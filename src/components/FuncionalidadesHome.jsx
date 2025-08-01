import React from "react";

export default function FuncionalidadesHome() {
  return (
    <div style={{ padding: "40px 38px 0 38px", flex: 1 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
        <span style={{ fontSize: 38, color: "#3d5fc5" }}>🏛️</span>
        <div>
          <h1 style={{ fontWeight: 800, fontSize: 32, margin: 0, color: "#1d365c" }}>
            Sistema de Análise Preditiva de Compras
          </h1>
          <div style={{ fontSize: 21, color: "#273a59", marginTop: 2 }}>
            Prefeitura de Cardeal da Silva – BA
          </div>
          <div style={{ fontSize: 16, color: "#444", marginTop: 3 }}>
            Inteligência Artificial aplicada à gestão de compras públicas
          </div>
        </div>
      </div>
      <div style={{
        margin: "32px 0 18px 0",
        background: "#fffbe7",
        border: "1px solid #f5e6a9",
        color: "#6c4a00",
        borderRadius: 7,
        padding: "16px 30px",
        fontSize: 18,
        fontWeight: 500,
        display: "flex",
        alignItems: "center",
        gap: 12
      }}>
        <span style={{ fontSize: 26 }}>🔒</span>
        <span>
          <b>Acesso Restrito</b><br />
          Este sistema é destinado exclusivamente aos servidores autorizados da Prefeitura de Silva.<br />
          Para acessar, utilize suas credenciais no painel lateral.
        </span>
      </div>
      <section>
        <div style={{ display: "flex", alignItems: "center", gap: 9 }}>
          <span style={{ fontSize: 32, color: "#d32121" }}>❯</span>
          <span style={{ fontWeight: 800, fontSize: 28, color: "#222" }}>
            Funcionalidades do Sistema
          </span>
        </div>
        <div style={{
          display: "flex", gap: 32, marginTop: 22, flexWrap: "wrap",
          fontSize: 19
        }}>
          {/* Inteligência Artificial */}
          <div style={{ minWidth: 260, flex: 1 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, fontWeight: 700, fontSize: 22 }}>
              <span style={{ color: "#3d4bba", fontSize: 28 }}>⚙️</span>
              Inteligência Artificial
            </div>
            <ul style={{ margin: "9px 0 0 0", paddingLeft: 20, color: "#222", fontSize: 16 }}>
              <li>Previsão de compras com Prophet</li>
              <li>Análise de tendências de mercado</li>
              <li>Detecção de oportunidades</li>
              <li>Clustering por similaridade</li>
            </ul>
          </div>
          {/* Coleta Automatizada */}
          <div style={{ minWidth: 260, flex: 1 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, fontWeight: 700, fontSize: 22 }}>
              <span style={{ color: "#1c90b9", fontSize: 28 }}>🛠️</span>
              Coleta Automatizada
            </div>
            <ul style={{ margin: "9px 0 0 0", paddingLeft: 20, color: "#222", fontSize: 16 }}>
              <li>Dados do PNCP em tempo real</li>
              <li>Diário Oficial automatizado</li>
              <li>Painel Nacional de Preços</li>
              <li>Histórico de contratações</li>
            </ul>
          </div>
          {/* Documentos Legais */}
          <div style={{ minWidth: 260, flex: 1 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, fontWeight: 700, fontSize: 22 }}>
              <span style={{ color: "#d0a101", fontSize: 28 }}>📑</span>
              Documentos Legais
            </div>
            <ul style={{ margin: "9px 0 0 0", paddingLeft: 20, color: "#222", fontSize: 16 }}>
              <li>Plano Anual de Contratações</li>
              <li>Justificativas de preços</li>
              <li>Relatórios técnicos</li>
              <li>Estudos preliminares</li>
            </ul>
          </div>
        </div>
      </section>
    </div>
  );
}