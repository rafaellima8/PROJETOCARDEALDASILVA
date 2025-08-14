def export_exec_report(path, kpis: dict, notes: str = ""):
    from reportlab.lib.pagesizes import A4
    from reportlab.pdfgen import canvas
    c = canvas.Canvas(path, pagesize=A4)
    w, h = A4; y = h - 50
    c.setFont("Helvetica-Bold", 14); c.drawString(50, y, "Relatório Mensal"); y -= 30
    c.setFont("Helvetica", 11)
    for k, v in kpis.items(): c.drawString(50, y, f"- {k}: {v}"); y -= 18
    if notes: y -= 10; c.drawString(50, y, notes)
    c.showPage(); c.save()
