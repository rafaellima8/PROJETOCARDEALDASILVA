import React, { useState } from "react";

const MENU_ITEMS = [
  { label: "Nova Contratação", key: "nova_contratacao", icon: "🛒" },
  { label: "Dashboard", key: "dashboard", icon: "📊" },
  { label: "Análise Preditiva", key: "analise_preditiva", icon: "🤖" },
  { label: "Plano de Contratações", key: "plano_contratacoes", icon: "📝" },
  { label: "Gerar Documentos", key: "gerar_documentos", icon: "📄" },
  { label: "Relatórios", key: "relatorios", icon: "📑" },
  { label: "Configurações", key: "configuracoes", icon: "⚙️" },
];

export default function Sidebar({ loggedIn, onLogin, menu, setMenu }) {
  const [user, setUser] = useState("");
  const [pass, setPass] = useState("");
  const [sector, setSector] = useState("Licitações");

  function submit(e) {
    e.preventDefault();
    onLogin(user, pass);
  }

  return (
    <aside style={{
      width: 300,
      background: "#f3f3f3",
      borderRight: "1px solid #e2e2e2",
      padding: "32px 22px 16px 22px",
      display: "flex",
      flexDirection: "column",
      gap: 24,
      minHeight: "100vh"
    }}>
      <div>
        <div style={{ fontWeight: 700, color: "#444", fontSize: 18, marginBottom: 10 }}>
          <span role="img" aria-label="cadeado">🔒</span> Acesso ao Sistema
        </div>
        <form onSubmit={submit} style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          <label style={{ fontWeight: 600, fontSize: 15, color: "#222" }}>Login do Servidor</label>
          <input
            type="text"
            placeholder="admin"
            value={user}
            disabled={loggedIn}
            onChange={e => setUser(e.target.value)}
            style={{
              background: "#f8f8f8", border: "1px solid #d3d3d3", borderRadius: 4,
              padding: 8, fontSize: 15
            }}
          />
          <input
            type="password"
            placeholder="admin"
            value={pass}
            disabled={loggedIn}
            onChange={e => setPass(e.target.value)}
            style={{
              background: "#f8f8f8", border: "1px solid #d3d3d3", borderRadius: 4,
              padding: 8, fontSize: 15
            }}
          />
          <select
            value={sector}
            disabled={loggedIn}
            onChange={e => setSector(e.target.value)}
            style={{
              background: "#f8f8f8", border: "1px solid #d3d3d3", borderRadius: 4,
              padding: 8, fontSize: 15
            }}>
            <option value="Licitações">Licitações</option>
            <option value="Compras">Compras</option>
            <option value="Contratos">Contratos</option>
          </select>
          <button
            type="submit"
            disabled={loggedIn || !user || !pass}
            style={{
              marginTop: 8,
              background: loggedIn ? "#b2e1b3" : "#1d365c",
              color: loggedIn ? "#222" : "#fff",
              fontWeight: 700,
              fontSize: 16,
              border: "none",
              borderRadius: 4,
              padding: "8px 0",
              cursor: loggedIn ? "default" : "pointer"
            }}>→ Entrar</button>
        </form>
      </div>
      <div>
        <div style={{ fontWeight: 600, fontSize: 17, color: "#222", marginBottom: 10 }}>Menu de Navegação</div>
        <ul style={{ listStyle: "none", padding: 0, margin: 0, display: "flex", flexDirection: "column", gap: 11 }}>
          {MENU_ITEMS.map(item => (
            <li key={item.key}>
              <button
                disabled={!loggedIn}
                onClick={() => setMenu(item.key)}
                style={{
                  display: "flex", alignItems: "center", gap: 10,
                  border: "none", background: "none", color: "#212a3b",
                  fontSize: 16, padding: "4px 0", cursor: loggedIn ? "pointer" : "not-allowed",
                  opacity: loggedIn ? 1 : 0.5, width: "100%", textAlign: "left"
                }}>
                <span>{item.icon}</span> {item.label}
              </button>
            </li>
          ))}
        </ul>
      </div>
    </aside>
  );
}
