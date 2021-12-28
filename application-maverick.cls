%% application-maverick.cls
%% Version: 1.0
%% Author:  Florian Sihler, 26.12.2019
%%
%% This LaTeX2e Class should provide a layout for typesetting a letter of
%% application. It's based on the design I've included into LILLY,
%% but being a standalone invariant it offers more customization options
%% including multiple pages of output and better parsing :D
%%                      ulm university, WiSe2019

%% Development notes:
%%    All internal commands and registers will be prefixed with 'apma@
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{application-maverick}[2019/26/02 Florian Sihler - Application Documentclass w. maverick-Design]

%% Lengths and Registers
%% -----------
% we will setup a bunch of registers and helpers which should NOT be modified
% directly, there are other macros and/or setting to help you configure them
% correctly or apply them at the right time!

\newif\ifapma@usedraft@ % draft mode will compile faster but won't render imgaes etc.
\newif\ifapma@dopar@% parlen control
\newif\ifapma@simplelayout@% no shading, enforced by draft

% generic registers
\newcounter{apma@counter@tmp@a}
\newlength\apma@length@tmp@a

% default holders
\newlength\apma@length@parindent

\newdimen\apma@length@bpskip \apma@length@bpskip=.25cm
\newdimen\apma@length@rightpad \apma@length@rightpad=.25cm
\newlength\apma@length@banner@w \apma@length@banner@w=8cm
\newlength\apma@length@titleimg@pt \apma@length@titleimg@pt=.75cm% ofs padding top
\newlength\apma@length@titleimg@w \apma@length@titleimg@w=6cm% total width/centered!

\newlength\apma@length@sieBar@curY \apma@length@sieBar@curY=\z@% total width/centered!
\newsavebox\apma@titleimage@container

\def\@apma@sidebar@buffer{}

\let\apma@debug\typeout

%% Class-Args
%% -----------
% draftmode:
\DeclareOption{draft}{ \apma@usedraft@true }
\DeclareOption{final}{ \apma@usedraft@false }
% parindent:
\DeclareOption{nopar}{ \apma@dopar@false }
\DeclareOption{dopar}{ \apma@dopar@true }
% parindent:
\DeclareOption{normal}{ \apma@simplelayout@false }
\DeclareOption{simple}{ \apma@simplelayout@true }

% in any case, the following options will be applied:
\ExecuteOptions{final,nopar,normal}% set it explicitly
\ProcessOptions\relax

% if in draft, we always stay simple :D
\ifapma@usedraft@ \apma@simplelayout@true \fi

%% Documentclass
%% -----------
% wie will use the default article as a starting-point
\LoadClass{article}

\apma@length@parindent=\parindent
\ifapma@dopar@ \parindent=\apma@length@parindent \else \parindent=\z@ \fi

%% Basic Packages
%% -----------
\PassOptionsToPackage{x11names}{xcolor}
\RequirePackage{tikz} % we need it anyways - will load xcolor
\usetikzlibrary{calc}
\ifapma@simplelayout@\else\usetikzlibrary{shadings}\fi

% encoding:
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}

% language
\RequirePackage[english,main=ngerman]{babel}

% layout
% should be configured bettter
\pgfmathsetmacro\apma@leftmargin{\apma@length@banner@w+.5cm}
\RequirePackage[left=\apma@leftmargin pt,top=.5cm,right=.5cm,bottom=.25cm,a4paper]{geometry}

% may we want to use math:
\RequirePackage{amsmath}

% beautify:
\RequirePackage{lmodern,microtype,multicol,calligra}
\RequirePackage{enumitem,graphicx,fontawesome,environ,ragged2e}

\PassOptionsToPackage{hidelinks}{hyperref}
\RequirePackage{attachfile2}

\RequirePackage[all]{nowidow}
\RequirePackage[hidelinks]{hyperref}
\urlstyle{same}

\usetikzlibrary{decorations.text}

%% Font
%% -----------
% By default, we will use the overclock font-base
\RequirePackage[sfdefault]{overlock}

%% Color Definitions
%% -----------
\def\apma@setColorProfile#1{%
\xglobal\colorlet{apma@color@primary}{#1}%
\xglobal\colorlet{apma@color@secondary}{apma@color@primary!42!black}%
\xglobal\colorlet{apma@color@page}{apma@color@primary!7!white}% hihi 007
\xglobal\colorlet{apma@color@flavour}{apma@color@page}%
}

\apma@setColorProfile{LavenderBlush4}% default
\let\setColorProfile\apma@setColorProfile

%% Page Background Fun :D
%% -----------
% we will assign nodes for later use so there is no need for recalculation
% note that all drawer commands have to be placed inside of a tikzpicture

% variant without shading :)
\def\apma@drawer@placebanner@simple{%
    \fill[apma@color@primary] (current page.north west) rectangle %
            ([xshift=\apma@length@banner@w]current page.south west);%
}
\def\apma@drawer@placebanner@shadey{%
\fill[lower left=apma@color@primary!2!apma@color@secondary,%
    lower right=apma@color@primary!2!apma@color@secondary,%
    upper left=apma@color@primary!50!apma@color@secondary,%
    upper right=apma@color@primary] (current page.north west) rectangle %
    ([xshift=\apma@length@banner@w]current page.south west);%
}


\def\apma@control@initpage{%
\pagecolor{apma@color@page}%
\begin{tikzpicture}[remember picture,overlay]
    \ifapma@simplelayout@\apma@drawer@placebanner@simple\relax
    \else\apma@drawer@placebanner@shadey\fi
\end{tikzpicture}%
}

% sloppy environment:
\newenvironment{ap-page}{%
    % reset title image in case of nodes, nested tikzpic :D
    \protected@edef\@tmp{\noexpand\apma@control@titleimage{\getData{image style}}{\getData{image}}}\@tmp
    % we reset the titlepage options here:
    \clearpage\apma@control@initpage
    \gdef\@apma@sidebar@buffer{}% emtpy the current buffer
    \apma@length@sieBar@curY=\z@
}{%
    % execute the sidebar processing
    {\apma@sidebar@init}
}

\newenvironment{ap-page*}{%
    % reset title image in case of nodes, nested tikzpic :D
    \protected@edef\@tmp{\noexpand\apma@control@titleimage{\getData{image style}}{\getData{image}}}\@tmp
    % we reset the titlepage options here:
    \clearpage\pagecolor{apma@color@page}%\apma@control@initpage%
    \gdef\@apma@sidebar@buffer{}% emtpy the current buffer
    \apma@length@sieBar@curY=\z@
    \newgeometry{left=1cm,right=1cm,top=1cm,bottom=1cm}%
}{\restoregeometry}

%% Generic Typesetters <3
%% -----------
% the goal is to set a picture in a rectangle/square, circle and hexagon :)
\tikzset{%
    apma@imgpath/.style 2 args={ path picture={%
        \node at(path picture bounding box.center) {\includegraphics[width=#1]{#2}};
}}}

% #1: path to image #2: width #3: center
\def\apma@drawer@image@square#1#2#3{%
    \draw[apma@imgpath={#2}{#1},apma@color@flavour] (#3)++(-#2/2,-#2/2) rectangle ++(#2,#2);%
}

% #1: path to image #2: radius #3: center
\def\apma@drawer@image@circle#1#2#3{%
    \draw[apma@imgpath={#2}{#1},apma@color@flavour] (#3) circle (#2/2);%
}

% #1: path to image #2: 'width on widest' #3: center
\def\apma@drawer@image@hexagon#1#2#3{%
    \pgfmathsetmacro\apma@length@tmp@a{#2/2}%
    \draw[apma@imgpath={#2}{#1},apma@color@flavour] (#3)++(0,-\apma@length@tmp@a pt) -- ++ (30:\apma@length@tmp@a pt) -- ++ (90:\apma@length@tmp@a pt) -- ++ (150:\apma@length@tmp@a pt) -- ++ (210:\apma@length@tmp@a pt) -- ++ (270:\apma@length@tmp@a pt) -- cycle;
}

% #1: drawer to check for available
\def\apma@util@checkimgdrawer#1{%
    \@ifundefined{apma@drawer@image@#1}{%
        \ClassError{application-maverick}{Der Stil '#1' steht nicht zur Verfuegung. Bitte waehle einen der folgenden: 'square', 'circle', 'hexagon'}{Please, choose another one :D}
    }{}%
}

% #1: style #2: imgpath
\def\apma@control@titleimage#1#2{%
\apma@util@checkimgdrawer{#1}%
\sbox{\apma@titleimage@container}{%
    \begin{tikzpicture}%
    \@nameuse{apma@drawer@image@#1}{#2}{\apma@length@titleimg@w}{0,0}%
    \end{tikzpicture}%
}
}

% #1 width #2 height #3 tikz extra
% #4 progress (0<=x<=1) #5 bordercol #6 progresscol
% #7 backcol (blank=transparent)
% #8 text for background
\def\apma@progressbar#1#2#3#4#5#6#7#8{%
\tikz[baseline=-.6ex]{\scope%
    \clip[#3] (0,0) rectangle (#1,#2);%Clip
    \ifx!#7!\def\@tmpcol{apma@color@flavour}\else\def\@tmpcol{#7}\fill[#7,thick] (0,0) rectangle (#1,#2);\fi% back
    \fill[#6] (0,0) rectangle (#4*#1,#2);% Progress
    \endscope\draw[#5,thick,#3] (0,0) rectangle (#1,#2);% border
    \ifx!#8!\else
        \node[below right,outer sep=0pt, inner sep=0pt,yshift=-.75pt,scale=.8,text=#6] at (0,0) {\strut#8};
        % \scope\clip[#3] (0,0) rectangle (#4*#1,#2);
        % \node[right,text=\@tmpcol,scale=.85] at(0,#2/2) {\strut#8};
        % \endscope
    \fi
}}

% #1 progress
\newcommand*\apma@progressbar@l[2][]{%
    \apma@progressbar{6.5em}{.65em}{rounded corners=.25em/2}{\ifdim#21pt>1pt #2/100.0\else#2\fi}{apma@color@flavour}{apma@color@flavour}{}{#1}%
}

% #1 progress
\newcommand*\apma@progressbar@s{%
    \@ifstar{\apma@progressbar@s@hlp}{\null\hfill\apma@progressbar@s@hlp}%
}
\newcommand*\apma@progressbar@s@hlp[2][]{\apma@progressbar{5.5em}{.65em}{rounded corners=.25em/2}{\ifdim#2pt>1pt #2/100.0\else#2\fi}{apma@color@primary!35!black}{apma@color@primary!35!black}{}{#1}}


\newcommand*\apma@progressbar@small@s[2][]{%
    \null\hfill\apma@progressbar{5em}{.65em}{rounded corners=.25em/2}{\ifdim#2pt>1pt #2/100.0\else#2\fi}{apma@color@primary!35!black}{apma@color@primary!35!black}{}{#1}%
}
%% Sidebar setup
%% -----------
% The sidebar can be setup as a list of blocks that should be placed
% they will be placed into one node basically being

% store all elements and place them here on end of environment, no replacement needed
\def\apma@sidebar@init{%
\let\progressbar\apma@progressbar@l% set right :D
\apma@debug{Setting Sidebar using '\@apma@sidebar@buffer'}%
% creating the node buffer
% in case of multiple rewrites we will keep a start-off point
\begin{tikzpicture}[remember picture,overlay]
    % init main node:
    \node[font=\getData{text font},apma@color@flavour,text width=\apma@length@banner@w,below=\z@,inner sep=\z@,align=center]%
        at($(current page.north west)+(\apma@length@banner@w/2,0)$)% \apma@length@sieBar@curY % placed at current top point facing below, no centering as multiple can occur
{% init
    \parbox[t][\textheight]{\linewidth}{%
    \pgfmathsetmacro\apma@sidebarb@twidth{\linewidth-1.25cm}% make wanted text width calculation in points
    % place schduff
    \foreach \element in \@apma@sidebar@buffer {%
        \apma@sideBar@checkValid{\element}% check for validity
        \apma@debug{Placing '\element'}%
        % place element
        \ignorespaces% may we have some naughty spaces :D
        \@nameuse{apma@sidebar@element@\element}%
    }%
    }%
};
\@pma@sidebar@exit{}}

\def\@pma@sidebar@exit{\end{tikzpicture}\relax}%

% eg: \setSidebar{title image,brief description,skills}
\@namedef{apma@sidebar@element@title image}{%
\null\expandafter\vskip\apma@length@titleimg@pt\begingroup
    \centering\usebox{\apma@titleimage@container}\\
\endgroup
}

\@namedef{apma@sidebar@element@nl}{\null\leavevmode\\\null}
\@namedef{apma@sidebar@element@space}{\null\vfill\null}

\def\apma@at{@}%
\def\apma@util@@middle#1#2\@nil{%
\def\tmp@a{#1}\ifx!#1!\else\ifx\apma@at\tmp@a\else \tmp@a.~\fi\fi
}

\def\apma@util@middle#1{%
    \protected@edef\@tmp{\noexpand\apma@util@@middle#1 @ \noexpand\@nil}\@tmp
}

\def\apma@util@constructname{%
    \getData{first name}~\expandafter\apma@util@middle{\getData{middle name}}\textbf{\getData{last name}}%
}

% [#1] raise
%  #2  thickness
\newcommand{\apma@raisedrule}[2][\z@]{\leaders\hbox{\rule[#1]{.01pt}{#2}}\hfill}

% #1 Symbol
% #2 Text
\def\apma@util@block#1#2{\begingroup\color{apma@color@flavour}\Large
\leavevmode\null\vskip.5em\hskip1em\relax\parbox{1.5em}{\centering\resizebox{1.25em}{!}{#1}\strut}~\MakeUppercase{#2}\(\;\)\apma@raisedrule[.25\baselineskip]{\p@}\smallskip\endgroup
}

\def\apma@brief@name{Kurzbeschreibung}
\def\apma@brief@symbol{\faUser}
\def\apma@sidebar@helper@brief{%
\apma@util@block{\apma@brief@symbol}{\apma@brief@name}\\\hspace*{2em}\parbox{\apma@sidebarb@twidth pt}{\justify\textbf{\getData{brief init}:} \getData{brief}}\\%
}
\@namedef{apma@sidebar@element@brief}{\apma@sidebar@helper@brief}
\@namedef{apma@sidebar@element@name}{{\centering\getData{name font}\apma@util@constructname\\}}
\@namedef{apma@sidebar@element@birthday}{{\centering\getData{text font}\getData{birthday}\\}}

\def\@apma@setcontacts#1#2#3#4{\global\addtocounter{apma@counter@bannermax}{-1}\@nameuse{@apma@l#4}{\getData{#3}}}


\def\apma@contact@name{Kontakt}
\def\apma@contact@symbol{\faComments}
\@namedef{apma@sidebar@element@contact}{%
\global\addtocounter{apma@counter@bannermax}{4}% every block has a right to set min 4 elements
\apma@util@block{\apma@contact@symbol}{\apma@contact@name}\\\hspace*{2em}\parbox{\apma@sidebarb@twidth pt}{%
\begin{apma@sidebar@itemize}
    \@apma@SetNElementsFromCmdListIfTheyExist{\theapma@counter@bannermax}{@apma@setcontacts}{%
        phone/phone,%
        mobile phone/mphone,%
        email/mail,%
        website/url,%
        location/location,%
        linkedin/linkedin%
    }
\end{apma@sidebar@itemize}
}}%

\def\@apma@setskill#1#2#3#4{\protected@edef\@numtg{#4}\global\addtocounter{apma@counter@bannermax}{-1} \item \ifx\@numtg\@empty{#3}\else{\parbox[t]{\tmp@smaller@lt pt}{#3}\hfill\apma@progressbar@l{#4}}\fi}

\def\apma@personalskill@name{Persönliche Fertigkeiten}
\def\apma@personalskill@symbol{\faPieChart}
\@namedef{apma@sidebar@element@personal skills}{%
\global\addtocounter{apma@counter@bannermax}{4}% every block has a right to set min 4 elements
\apma@util@block{\apma@personalskill@symbol}{\apma@personalskill@name}\\\hspace*{2em}\parbox{\apma@sidebarb@twidth pt}{%
\pgfmathsetmacro\tmp@smaller@lt{\linewidth-3.75cm}
\protected@edef\@tmp{\noexpand\@applications@SetNElementsFromList{\theapma@counter@bannermax}{@apma@setskill}{\getData{skills}}}
\begin{apma@sidebar@itemize}
    \@tmp
\end{apma@sidebar@itemize}
}}%

\def\apma@contact@name{Soziale Netzwerke}
\def\apma@contact@symbol{\faUsers}
\@namedef{apma@sidebar@element@social contact}{%
\global\addtocounter{apma@counter@bannermax}{4}% every block has a right to set min 4 elements
\apma@util@block{\apma@contact@symbol}{\apma@contact@name}\\\hspace*{2em}\parbox{\apma@sidebarb@twidth pt}{%
\begin{apma@sidebar@itemize}
    \@apma@SetNElementsFromCmdListIfTheyExist{\theapma@counter@bannermax}{@apma@setcontacts}{%
        instagram/instagram,facebook/facebook,%
        twitter/twitter,rss/rss,%
        steam/steam,soundcloud/soundcloud,%
        wordpress/wordpress,xing/xing,%
        youtube/youtube,reddit/reddit,%
        github/github,gitlab/gitlab,%
        telegram/telegram,dropbox/dropbox,%
        slack/slack%
    }
\end{apma@sidebar@itemize}
}}%

% checker:
\def\apma@sideBar@checkValid#1{%
    \@ifundefined{apma@sidebar@element@#1}{%
        \ClassError{application-maverick}{Das Element '#1' existiert nicht}{Please check for typos.}
    }{}%
}
\def\apma@setSideBarElement#1{%
    \apma@sideBar@checkValid{#1}%
    \@nameuse{apma@sidebar@element@#1}%
}
\let\setSideBarElement\apma@setSideBarElement

\def\apma@setSideBarElements#1{%
    \apma@debug{Buffers was: '\@apma@sidebar@buffer'}%
    \let\@oldbuf\@apma@sidebar@buffer%
    \ifx\@oldbuf\@empty% first element in list
        \protected@xdef\@apma@sidebar@buffer{\expandafter\noexpand#1}%
        \apma@debug{Init, setting '#1' as first element(s)}%
    \else% append
        \protected@xdef\@apma@sidebar@buffer{\expandafter\noexpand\@oldbuf\expandafter\noexpand#1}%
        \apma@debug{Appendig, adding '#1'}%
    \fi
    \apma@debug{Buffer is: '\@apma@sidebar@buffer'}
}
\let\setSideBarElements\apma@setSideBarElements

%% Icons for Social Media
%% -----------
\foreach \xcs/\symfa in {%
    facebook/faFacebookSquare,instagram/faInstagram,%
    twitter/faTwitter,rss/faRss,%
    linkedin/faLinkedin,steam/faSteamSquare,%
    soundcloud/faSoundcloud,wordpress/faWordpress,%
    xing/faXing,youtube/faYoutubePlay,%
    reddit/faReddit,github/faGithubSquare,%
    gitlab/faGitlab,telegram/faPaperPlane,%
    dropbox/faDropbox,slack/faSlack,%
    phone/faPhone,mphone/faMobile,%
    mail/faEnvelope,url/faGlobe,%
    location/faMapMarker%
}{%
    \expandafter\protected@xdef\csname @apma@l\xcs\endcsname##1{\noexpand\item[{\noexpand\makebox[1em][c]{\noexpand\color{apma@color@flavour}\expandafter\noexpand\csname\symfa\endcsname}}] ##1}%
}

%% -----------
%% Register Placement for sidebar, note that they can be cleared :D
%% -----------


% List of all supported, permanent registers
\def\apma@regiters@permanent{%
    first name,last name,birthday,image,image style,%
    middle name,title,brief,brief init,name font,%
    text font,%
    phone,mobile phone,email,website,location,%
    address, address 2,%
    % social media
    instagram,facebook,twitter,rss,linkedin,%
    steam,soundcloud,wordpress,xing,youtube,%
    reddit,github,gitlab,telegram,dropbox,slack%
}

\def\apma@init@registers#1{%
    \foreach \cst in #1 {%
        \expandafter\gdef\csname apma@register@person@\cst @value\endcsname{}
    }%
}%

% checker:
\def\apma@util@checkValid#1{%
    \@ifundefined{apma@register@person@#1@value}{%
        \ClassError{application-maverick}{Das Feld '#1' existiert nicht}{Please check for typos.}
    }{}%
}

% getter:
\def\apma@util@getUser#1{\apma@util@checkValid{#1}\@nameuse{apma@register@person@#1@value}}
\let\getData\apma@util@getUser
% setter:
\def\apma@util@setUser#1#2{\apma@util@checkValid{#1}\begingroup\expandafter\gdef\csname apma@register@person@#1@value\endcsname{#2}\endgroup}

\let\setData\apma@util@setUser

% init global registers:
\apma@init@registers\apma@regiters@permanent \relax

% no we write a convenient Setter interface:
\def\apma@util@@setAll@parseline#1: #2\@nil{\apma@util@setUser{#1}{#2}}

\def\apma@util@@setAll#1{%
% as foreach gets loaded:
\foreach \line in {#1} {% check empty
    \ifx\line\@empty\else
        \expandafter\apma@util@@setAll@parseline\line \@nil
    \fi
}}

% wrapper
\long\def\apma@util@setAll#1{\apma@util@@setAll{#1}}
\let\setAll\apma@util@setAll

% defaults:
\setAll{%
    first name: Vorname,
    last name: Nachname,
    image style: hexagon,
    name font: \Huge, text font: \large
}


%% -----------
%% Skill management
%% -----------

\def\apma@register@person@skills@value{} % list of skills always with Text and Progress, if the progress is EMPTY (!= 0) no bar will be set and  no space inserted.they should only be managed by the following iterfaces to avoid nonworking skilllists

\def\@apma@clearskills{\gdef\apma@register@person@skills@value{}}

% currently unused
\def\@@apma@setskills#1{%
    \gdef\apma@register@person@skills@value{#1}%
}

\def\@apma@addskill#1#2{%
    \protected@edef\@@apma@skills@last{\apma@register@person@skills@value}%
    \ifx\apma@register@person@skills@value\@empty
        \protected@xdef\apma@register@person@skills@value{{#1}/{#2}}%
    \else
        \protected@xdef\apma@register@person@skills@value{\@@apma@skills@last,{#1}/{#2}}%
    \fi
}

\let\addSkill\@apma@addskill
\def\addSkillText#1{\@apma@addskill{#1}{}}

%% -----------
%% Standalone List-Control helper
%% -----------
\let\c@apma@counter@bannermax\relax

\newcounter{apma@counter@bannermax}%
% \setcounter{apma@counter@bannermax}{4}% will be handled by blocks

\newcounter{apma@counter@elemc}
% Typesets up to #1 Elements from a List, if they're Commands exist
% they will be passed to #2, which should be a csname consuming exactly four arguments:
%       ##1: current element counter
%       ##2: current total counter in list
%       ##3: existing csname
%       ##4: tag passed with the list:
% #3 The List of csnames in the shape of "csname/tag" whereas tag will be
%
\def\@apma@SetNElementsFromCmdListIfTheyExist#1#2#3{%
    \protected@edef\@cmax{#1}%
    \setcounter{apma@counter@elemc}{0}
    \ifnum\@cmax<1\else% Handle the zero or less case which should be the 'i am stupid' case :D, hopefully
    \foreach \element/\tag [count=\i] in {#3}{%
        \protected@edef\@tmp{\expandafter\@nameuse{apma@register@person@\element @value}}
        \ifx\@tmp\@empty
        \else% is it set?
            \csname#2\endcsname{\i}{\theapma@counter@elemc}{\element}{\tag}%
            \stepcounter{apma@counter@elemc}%
        \fi
        \ifnum\theapma@counter@elemc=\@cmax \breakforeach\fi% breakforeach will continue the current execution therefore we will tailcheck
    }%
    \fi
}

% Typesets up to #1 Elements from a List,
% they will be passed to #2, which should be a csname consuming exactly four arguments:
%       ##1: current element counter
%       ##2: current total counter in list
%       ##3: text
%       ##4: tag passed with the list:
% #3 The List of texts in the shape of "text/tag" whereas tag will be
%
\def\@applications@SetNElementsFromList#1#2#3{%
    \protected@edef\@cmax{#1}%
    \ifnum\@cmax<1\else% Handle the zero or less case which should be the 'i am stupid' case :D, hopefully
    \foreach \element/\tag [count=\i] in {#3}{%
        \csname#2\endcsname{\i}{\i}{\element}{\tag}%
        \ifnum\i=\@cmax \breakforeach\fi% breakforeach will continue the current execution therefore we will tailcheck
    }%
    \fi
}

\NewEnviron{apma@sidebar@itemize}[1][]{\begingroup\hypersetup{urlcolor={apma@color@flavour}}%
\vspace*{-.125em}\relax\parbox{\linewidth}{\begin{itemize}[label={\makebox[1em][c]{\color{apma@color@flavour}\large$\bullet$}},leftmargin=*,#1]\leftmargin=\z@\labelsep=.75em%
    \BODY\end{itemize}}\endgroup
}

\let\sbitemize\apma@sidebar@itemize
\let\endsbitemize\endapma@sidebar@itemize

%% -----------
%% Main Block fun
%% -----------

\def\apmaeventsecondfont{\footnotesize}
\NewEnviron{apma@event}[3]{%
\item[\color{apma@color@primary!75!black}\raisebox{.5pt}{$\bullet$}] {\color{apma@color@primary!75!black}\textbf{#1}\ifx!#3!\else\hskip.5em\relax/\hskip.5em\relax{\apmaeventsecondfont#3\null}\fi{\hfill#2}\hskip\apma@length@rightpad}\\[.1em]\pgfmathsetmacro\@newpblen{\linewidth-\apma@length@rightpad}\parbox[t]{\@newpblen pt}{\BODY}\medskip
}%
%

% #1 number of cols
\NewEnviron{apma@bulletpoints}[1][]{\leavevmode\newline\indent
    \ifnum\@listdepth=\@ne \apma@length@bpskip=.075cm\else \apma@length@bpskip=.25cm\fi
    \pgfmathsetmacro\@pb@stlen{\linewidth-1cm+\apma@length@bpskip}%
    \hskip-\apma@length@bpskip\parbox{\@pb@stlen pt}{%
    \ifx!#1!\else\begin{multicols}{#1}\vspace*{-1.5\baselineskip}\fi
    \begin{itemize}[topsep=4pt, label={\color{apma@color@primary!75!black}\ifnum\@listdepth=\@ne \raisebox{.5pt}{$\bullet$}\else\raisebox{1.25pt}{\scriptsize$\bullet$}\fi},itemsep=2pt]%
        \BODY
    \end{itemize}%
    \ifx!#1!\else\end{multicols}\fi
    }%
}%
\NewEnviron{apma@text}{%
    \pgfmathsetmacro\@pb@txt@stlen{\linewidth-\apma@length@rightpad-.3cm}%
    \hskip.3cm\relax\parbox{\@pb@txt@stlen pt}{\BODY}%
}
% if #1 given it will sign with tese words
\def\signtext{Mit freundlichen Grüßen:}
\newcommand*\sign[1][]{\@@sign{\huge\calligra{} #1\\[-.35\baselineskip]}}%
\newcommand*\signimg[1]{\@@sign{\includegraphics[width=\linewidth]{#1}\\[-.65\baselineskip]}}%
\def\@@sign#1{%
\null\vskip.125em\null\vfill\hskip1cm\signtext
    \null\vskip2.125em\begin{flushright}% Unterschrift
        \parbox[t]{6cm}{%
            \centering
            \ifx!#1!{\huge\strut}\else{#1}\fi
            \rule{5cm}{\p@}\\
            \apma@util@constructname\relax,\hskip.75em\relax\heute
        }\hspace*{.5cm}
    \end{flushright}\vskip.75cm%
}%
%


% #1 Symbol
% #2 Text
\def\@apma@StartBlock#1#2{\begingroup\color{apma@color@primary!75!black}\Large
\pgfmathsetmacro\@mplen{\textwidth+2cm}
\begin{minipage}{\@mplen pt}%
    \leavevmode\newline\null\relax\parbox{1.5em}{#1\strut}~\MakeUppercase{#2}\(\;\)\apma@raisedrule[.25\baselineskip]{1.25pt}\smallskip
\end{minipage}\endgroup\ }

\def\apma@block@init{%
\let\bulletpoints\apma@bulletpoints \let\endbulletpoints\endapma@bulletpoints
\let\text\apma@text \let\endtext\endapma@text
}
%
%
% [#1] Symbol
%  #2  Title
\newenvironment{block}[2][]{\begingroup
    \let\progressbar\apma@progressbar@s
    \let\progressbarSmall\apma@progressbar@small@s
    \@apma@StartBlock{#1}{#2}
    \begin{minipage}{\linewidth}\ignorespaces
    \apma@block@init
}
{\end{minipage}\endgroup\medskip}

\NewEnviron{timeline}{%
    \apma@block@init
    \let\event\apma@event \let\endevent\endapma@event
    \pgfmathsetmacro\@parbtlen{\linewidth+.25cm}
    \hskip-.25cm\parbox{\@parbtlen pt}{\begin{itemize}
        \BODY
    \end{itemize}}%
}%


%% Cake diagram ;)
%% -----------
\def\@cake@slice#1#2#3#4#5{
  \pgfmathsetmacro\midangle{.5*#1+.5*#2}%
  \pgfmathsetmacro\hookstart{#1+5}
  \pgfmathsetmacro\hookend{#2-5}
  % slice
  \draw[thick,#5,fill=#5,fill opacity=.05] (0,0) -- (#1:1) arc (#1:#2:1) -- cycle;
  \path[postaction={decorate,decoration={text along path,text align={center},text={|\scriptsize\color{#5}|\t}}},#5] (\hookstart:1.05) arc (\hookstart:\hookend:1.05);
  \node[#5,scale=.760] at (\midangle:.685) {#3};
}
\newcounter{cake@slice@counter@a}
\newcounter{cake@slice@counter@b}

\newcommand*\Cake[2][6cm]{%
\setcounter{cake@slice@counter@a}{0}%
\setcounter{cake@slice@counter@b}{0}%
\resizebox{#1}{!}{%
    \begin{tikzpicture}[scale=1.85]%
    \foreach \p/\t in {#2}{%
        \setcounter{cake@slice@counter@a}{\value{cake@slice@counter@b}}%
        \addtocounter{cake@slice@counter@b}{\p}%
        \@cake@slice{\thecake@slice@counter@b/100*360}
            {\thecake@slice@counter@a/100*360}
            {\p\%}{\t}{apma@color@page}
    }
    \end{tikzpicture}%
}%
}

\newcommand*\MakeCake[3][6cm]{%
\AtBeginDocument{%
\expandafter\newsavebox\csname a@cake@named@#2\endcsname%
\sbox{\csname a@cake@named@#2\endcsname}{\Cake[#1]{#3}}}%
}

\newcommand*\PlaceCake[1]{%
{\smallskip\centering\usebox{\csname a@cake@named@#1\endcsname}\smallskip}%
}

%% Helper
%% -----------
\def\apma@mail#1{\href{mailto:#1}{#1}}
\let\mail\apma@mail
\def\heute{\number\day.~\month@ngerman\space\number\year}

\long\def\CreateElement#1#2{\expandafter\gdef\csname apma@sidebar@element@#1\endcsname{#2}}

\providecommand\expandonce[1]{\unexpanded\expandafter{#1}}
% #1 Name of the element #2 Symbol of the Block #3 Text of the Block title #4 Content of the block
\long\def\CreateBlockElement#1#2#3#4{%
\CreateElement{#1}{%
    \apma@util@block{#2}{#3}\\\hspace*{2em}\parbox{\apma@sidebarb@twidth pt}{%
        \ignorespaces#4\relax
    }
}}

\def\ChangeSymbol#1#2{\expandafter\gdef\csname apma@#1@symbol\endcsname{#2}}

\pagenumbering{gobble}

\newcommand\AttachFile[2][]{%
\ifx!#1!\textattachfile{#2}{#2}\else
\textattachfile{#2}{#1}\fi}

\providecommand\@linkshade{90}
\providecommand\@linkmix{white}
\AtBeginDocument{
\attachfilesetup{%
    author={\getData{first name} \getData{last name}},
    color=apma@color@primary!\@linkshade!\@linkmix,
    icon=Tag,
    mimetype=text/plain % we assume
}}

\newcommand*\setLinkShade[2][white]{\gdef\@linkmix{#1}\gdef\@linkshade{#2}}
\renewcommand*\thempfootnote{$\langle$\textbf{\arabic{mpfootnote}}$\rangle$}
\endinput