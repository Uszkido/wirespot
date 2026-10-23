from pathlib import Path
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (BaseDocTemplate, PageBreak, PageTemplate,
                                Paragraph, Spacer, Table, TableStyle,
                                KeepTogether)
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs' / 'WireSpot Technical Manual.md'
OUT = ROOT / 'output' / 'pdf' / 'WireSpot Technical Manual.pdf'
OUT.parent.mkdir(parents=True, exist_ok=True)

PAGE_W, PAGE_H = A4
BLUE = colors.HexColor('#1E88E5')
NAVY = colors.HexColor('#0B1730')
INK = colors.HexColor('#25324A')
MUTED = colors.HexColor('#64748B')
PALE = colors.HexColor('#EEF6FF')

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='CoverTitle', parent=styles['Title'], fontName='Helvetica-Bold', fontSize=28, leading=33, textColor=NAVY, alignment=TA_CENTER, spaceAfter=8))
styles.add(ParagraphStyle(name='CoverSub', parent=styles['Normal'], fontName='Helvetica', fontSize=12, leading=18, textColor=MUTED, alignment=TA_CENTER))
styles.add(ParagraphStyle(name='H1x', parent=styles['Heading1'], fontName='Helvetica-Bold', fontSize=18, leading=22, textColor=NAVY, spaceBefore=10, spaceAfter=8, keepWithNext=True))
styles.add(ParagraphStyle(name='H2x', parent=styles['Heading2'], fontName='Helvetica-Bold', fontSize=12.5, leading=16, textColor=BLUE, spaceBefore=9, spaceAfter=5, keepWithNext=True))
styles.add(ParagraphStyle(name='Bodyx', parent=styles['BodyText'], fontName='Helvetica', fontSize=9.6, leading=14, textColor=INK, spaceAfter=6))
styles.add(ParagraphStyle(name='Smallx', parent=styles['BodyText'], fontName='Helvetica', fontSize=8.2, leading=11, textColor=MUTED))
styles.add(ParagraphStyle(name='TableHead', parent=styles['BodyText'], fontName='Helvetica-Bold', fontSize=8.2, leading=11, textColor=colors.white))
styles.add(ParagraphStyle(name='Bulletx', parent=styles['BodyText'], fontName='Helvetica', fontSize=9.4, leading=13, textColor=INK, leftIndent=13, firstLineIndent=-8, spaceAfter=3))
styles.add(ParagraphStyle(name='CodeX', parent=styles['Code'], fontName='Courier', fontSize=8.1, leading=11, textColor=colors.HexColor('#E6F1FF'), backColor=colors.HexColor('#14243D'), borderPadding=7, leftIndent=5, rightIndent=5, spaceBefore=3, spaceAfter=7))

def esc(text):
    return (text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;'))

def inline(text):
    text = esc(text)
    import re
    text = re.sub(r'`([^`]+)`', r'<font name="Courier" color="#075985">\1</font>', text)
    text = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', text)
    return text

def parse_md(text):
    story = []
    lines = text.splitlines()
    i = 0
    first_h1 = True
    while i < len(lines):
        line = lines[i].rstrip()
        if not line:
            i += 1; continue
        if line.startswith('# '):
            if first_h1:
                story += [Spacer(1, 42*mm), Paragraph(inline(line[2:]), styles['CoverTitle']), Spacer(1, 4*mm), Paragraph('Technical manual for operators, technicians, and support teams', styles['CoverSub']), Spacer(1, 9*mm), Paragraph('Vexel Innovations  |  in collaboration with TechNova Technologies', styles['CoverSub']), Spacer(1, 8*mm), Paragraph('Release line 1.0.x  |  October 2026', styles['CoverSub']), PageBreak()]
                first_h1 = False
            else: story.append(Paragraph(inline(line[2:]), styles['H1x']))
            i += 1; continue
        if line.startswith('## '):
            story.append(Paragraph(inline(line[3:]), styles['H1x'])); i += 1; continue
        if line.startswith('### '):
            story.append(Paragraph(inline(line[4:]), styles['H2x'])); i += 1; continue
        if line.startswith('```'):
            code = []; i += 1
            while i < len(lines) and not lines[i].startswith('```'):
                code.append(lines[i]); i += 1
            i += 1
            story.append(Paragraph(esc('\n'.join(code)).replace('\n','<br/>'), styles['CodeX'])); continue
        if line.startswith('|'):
            rows = []
            while i < len(lines) and lines[i].startswith('|'):
                raw = [x.strip() for x in lines[i].strip('|').split('|')]
                if not all(set(x) <= set('-: ') for x in raw):
                    cell_style = styles['TableHead'] if not rows else styles['Smallx']
                    rows.append([Paragraph(inline(x), cell_style) for x in raw])
                i += 1
            if rows:
                colw = (PAGE_W - 34*mm) / len(rows[0])
                t = Table(rows, colWidths=[colw]*len(rows[0]), repeatRows=1)
                t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),NAVY),('TEXTCOLOR',(0,0),(-1,0),colors.white),('GRID',(0,0),(-1,-1),0.35,colors.HexColor('#B6C7DC')),('BACKGROUND',(0,1),(-1,-1),PALE),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),6),('RIGHTPADDING',(0,0),(-1,-1),6),('TOPPADDING',(0,0),(-1,-1),5),('BOTTOMPADDING',(0,0),(-1,-1),5)]))
                story += [Spacer(1,3*mm), t, Spacer(1,3*mm)]
            continue
        if line.startswith('- '):
            story.append(Paragraph('• ' + inline(line[2:]), styles['Bulletx'])); i += 1; continue
        if len(line) >= 3 and line[0].isdigit() and line[1] == '.' and line[2] == ' ':
            story.append(Paragraph(inline(line), styles['Bodyx'])); i += 1; continue
        story.append(Paragraph(inline(line), styles['Bodyx'])); i += 1
    return story

def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(NAVY); canvas.rect(0, PAGE_H-13*mm, PAGE_W, 13*mm, fill=1, stroke=0)
    canvas.setFillColor(colors.white); canvas.setFont('Helvetica-Bold', 9); canvas.drawString(17*mm, PAGE_H-8.5*mm, 'WireSpot')
    canvas.setFont('Helvetica', 8); canvas.drawRightString(PAGE_W-17*mm, PAGE_H-8.5*mm, 'Technical Manual')
    canvas.setStrokeColor(colors.HexColor('#D8E4F1')); canvas.line(17*mm, 14*mm, PAGE_W-17*mm, 14*mm)
    canvas.setFillColor(MUTED); canvas.setFont('Helvetica', 8); canvas.drawString(17*mm, 8*mm, 'Vexel Innovations  |  TechNova Technologies')
    canvas.drawRightString(PAGE_W-17*mm, 8*mm, f'Page {doc.page}')
    canvas.restoreState()

class ManualDocTemplate(BaseDocTemplate):
    def __init__(self, filename, **kw):
        super().__init__(filename, **kw)
        frame = __import__('reportlab.platypus').platypus.Frame(17*mm, 19*mm, PAGE_W-34*mm, PAGE_H-39*mm, id='normal')
        self.addPageTemplates([PageTemplate(id='manual', frames=frame, onPage=header_footer)])

doc = ManualDocTemplate(str(OUT), pagesize=A4, title='WireSpot Technical Manual', author='Vexel Innovations')
doc.build(parse_md(SOURCE.read_text(encoding='utf-8')))
print(OUT)
