import React, { useState } from "react";
import Sidebar from "./components/Sidebar";
import FuncionalidadesHome from "./components/FuncionalidadesHome";
import Rodape from "./components/Rodape";
import NovaContratacao from "./pages/NovaContratacao.jsx";
import Dashboard from "./pages/Dashboard.jsx";
import AnalisePreditiva from "./pages/AnalisePreditiva.jsx";
import PlanoContratacoes from "./pages/PlanoContratacoes.jsx";
import GerarDocumentos from "./pages/GerarDocumentos.jsx";
import Relatorios from "./pages/Relatorios.jsx";
import Configuracoes from "./pages/Configuracoes.jsx";

export default function App() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [menu, setMenu] = useState("home");

  function handleLogin(user, pass) {
    if (user === "admin" && pass === "admin") setLoggedIn(true);
  }

  const renderPage = () => {
    if (!loggedIn) return <FuncionalidadesHome />;
    switch (menu) {
      case "nova_contratacao": return <NovaContratacao />;
      case "dashboard": return <Dashboard />;
      case "analise_preditiva": return <AnalisePreditiva />;
      case "plano_contratacoes": return <PlanoContratacoes />;
      case "gerar_documentos": return <GerarDocumentos />;
      case "relatorios": return <Relatorios />;
      case "configuracoes": return <Configuracoes />;
      default: return <FuncionalidadesHome />;
    }
  };

  return (
    <div style={{ minHeight: "100vh", background: "#fafafa", display: "flex" }}>
      <Sidebar
        loggedIn={loggedIn}
        onLogin={handleLogin}
        menu={menu}
        setMenu={setMenu}
      />
      <main style={{ flex: 1, background: "#fff", minHeight: "100vh", display: "flex", flexDirection: "column" }}>
        {renderPage()}
        <Rodape />
      </main>
    </div>
  );
}cd