\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}[2026/07/17 Single-column academic resume]

\LoadClass[10pt,a4paper]{article}

\RequirePackage{iftex}
\ifPDFTeX
  \RequirePackage[T1]{fontenc}
  \RequirePackage[scaled=0.95]{helvet}
  \renewcommand{\familydefault}{\sfdefault}
\else
  \RequirePackage{fontspec}
  \IfFontExistsTF{Helvetica}{%
    \setmainfont{Helvetica}
    \setsansfont{Helvetica}
  }{%
    \setmainfont{TeX Gyre Heros}
    \setsansfont{TeX Gyre Heros}
  }
  \renewcommand{\familydefault}{\sfdefault}
\fi

\RequirePackage[left=1.45cm,right=1.45cm,top=1.25cm,bottom=1.25cm]{geometry}
\RequirePackage{array}
\RequirePackage{graphicx}
\RequirePackage{tabularx}
\RequirePackage{xcolor}
\RequirePackage{enumitem}
\RequirePackage{microtype}
\RequirePackage[hidelinks]{hyperref}
\urlstyle{same}

\definecolor{sectioncolor}{HTML}{2E2E2E}
\definecolor{muted}{HTML}{5F6368}
\definecolor{rulecolor}{HTML}{B8BCC2}

\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\setlength{\tabcolsep}{0pt}
\pagestyle{empty}

\setlist[itemize]{
  leftmargin=1.25em,
  itemsep=1.5pt,
  topsep=2pt,
  parsep=0pt,
  partopsep=0pt
}

\newcommand{\clink}[1]{#1}

\newcommand{\csection}[2]{%
  \vspace{15pt}%
  {\large\bfseries\color{sectioncolor}\MakeUppercase{#1}}\par
  \vspace{0.16em}%
  {\color{rulecolor}\hrule height 0.6pt}%
  \vspace{0.35em}%
  #2%
}

\newcommand{\resumeentry}[4]{%
  \textbf{#1}\hfill\textbf{#2}\par
  \textit{#3}\hfill{\color{muted}#4}\par
}

\newcommand{\publicationentry}[3]{%
  \begin{tabularx}{\linewidth}{@{}X >{\raggedleft\arraybackslash}p{2.2cm}@{}}
    \textbf{#1} & \textit{#3} \\
    \multicolumn{2}{@{}l@{}}{#2}
  \end{tabularx}\par
}

\newcommand{\presentationentry}[2]{%
  \textbf{#1}\par
  \textit{#2}\par
}
