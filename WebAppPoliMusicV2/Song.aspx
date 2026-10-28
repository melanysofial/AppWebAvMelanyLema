<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic · Canciones</title>
    <style type="text/css">
        :root {
            --pink-100: #ffe6f0;
            --pink-200: #ffcfe1;
            --pink-300: #ffaacb;
            --pink-400: #ff80b0;
            --pink-500: #ff4d94;
            --pink-600: #e63a80;
            --ink: #3b2430;
            --ink-soft: #6d5462;
            --muted: #967d8a;
            --glass: rgba(255, 255, 255, 0.55);
            --glass-strong: rgba(255, 255, 255, 0.74);
            --glass-soft: rgba(255, 255, 255, 0.35);
            --stroke: rgba(255, 255, 255, 0.85);
            --stroke-soft: rgba(255, 255, 255, 0.55);
            --shadow: 0 20px 45px -22px rgba(205, 70, 130, 0.55);
        }

        * {
            box-sizing: border-box;
        }

        html, body {
            margin: 0;
            padding: 0;
        }

        body {
            min-height: 100vh;
            font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
            color: var(--ink);
            background:
                radial-gradient(1100px 700px at 5% -12%, #ffe2ee 0%, rgba(255, 255, 255, 0) 62%),
                radial-gradient(950px 620px at 102% -5%, #ffedf5 0%, rgba(255, 255, 255, 0) 58%),
                radial-gradient(900px 700px at 50% 115%, #ffe8f2 0%, rgba(255, 255, 255, 0) 60%),
                #fffafc;
            background-attachment: fixed;
            overflow-x: hidden;
        }

        /* ---------- decorative blurred blobs ---------- */
        .blobs {
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
            overflow: hidden;
        }

        .blob {
            position: absolute;
            border-radius: 50%;
            filter: blur(70px);
            opacity: .55;
            animation: float 16s ease-in-out infinite;
        }

        .blob-1 {
            width: 420px;
            height: 420px;
            left: -120px;
            top: 40px;
            background: #ffb8d4;
        }

        .blob-2 {
            width: 360px;
            height: 360px;
            right: -90px;
            top: 180px;
            background: #ffd9e8;
            animation-delay: -5s;
        }

        .blob-3 {
            width: 300px;
            height: 300px;
            left: 45%;
            bottom: -120px;
            background: #ffc6dd;
            animation-delay: -9s;
        }

        @keyframes float {
            0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
            50% { transform: translate3d(0, -26px, 0) scale(1.06); }
        }

        /* ---------- glass primitive ---------- */
        .glass {
            background: var(--glass);
            -webkit-backdrop-filter: blur(22px) saturate(165%);
            backdrop-filter: blur(22px) saturate(165%);
            border: 1px solid var(--stroke);
            box-shadow: var(--shadow);
            border-radius: 22px;
        }

        form {
            position: relative;
            z-index: 1;
        }

        /* ---------- layout ---------- */
        .app {
            display: grid;
            grid-template-columns: 258px minmax(0, 1fr);
            gap: 18px;
            padding: 18px 18px 132px;
            max-width: 1500px;
            margin: 0 auto;
            align-items: start;
        }

        /* ---------- sidebar ---------- */
        .sidebar {
            position: sticky;
            top: 18px;
            padding: 20px 16px;
            display: flex;
            flex-direction: column;
            gap: 22px;
            min-height: calc(100vh - 168px);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 11px;
            padding: 2px 6px 0;
        }

        .brand-logo {
            width: 40px;
            height: 40px;
            border-radius: 13px;
            display: grid;
            place-items: center;
            color: #fff;
            background: linear-gradient(145deg, var(--pink-400), var(--pink-600));
            box-shadow: 0 10px 22px -8px rgba(230, 58, 128, .85);
        }

        .brand-name {
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -.3px;
        }

        .brand-name span {
            color: var(--pink-500);
        }

        .nav-label {
            font-size: 10.5px;
            font-weight: 700;
            letter-spacing: 1.4px;
            text-transform: uppercase;
            color: var(--muted);
            padding: 0 8px 10px;
        }

        .nav {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            border-radius: 13px;
            font-size: 14px;
            font-weight: 600;
            color: var(--ink-soft);
            text-decoration: none;
            transition: background .18s ease, color .18s ease;
        }

        .nav-item svg {
            flex: 0 0 auto;
            opacity: .75;
        }

        .nav-item:hover {
            background: var(--glass-soft);
            color: var(--ink);
        }

        .nav-item.is-active {
            color: var(--pink-600);
            background: linear-gradient(120deg, rgba(255, 255, 255, .92), rgba(255, 214, 231, .78));
            box-shadow: 0 10px 22px -16px rgba(205, 70, 130, .9);
        }

        .nav-item.is-active svg {
            opacity: 1;
        }

        .sidebar-card {
            margin-top: auto;
            padding: 15px 15px 16px;
            border-radius: 17px;
            background: var(--glass-strong);
            border: 1px solid var(--stroke);
            box-shadow: 0 14px 30px -20px rgba(205, 70, 130, .8);
        }

        .sidebar-card h4 {
            margin: 0 0 10px;
            font-size: 12px;
            letter-spacing: 1.1px;
            text-transform: uppercase;
            color: var(--muted);
        }

        .stat {
            display: flex;
            align-items: baseline;
            gap: 7px;
            font-size: 13px;
            color: var(--ink-soft);
            padding: 3px 0;
        }

        .stat b {
            font-size: 19px;
            font-weight: 700;
            color: var(--pink-600);
            letter-spacing: -.4px;
        }

        /* ---------- topbar ---------- */
        .main {
            display: flex;
            flex-direction: column;
            gap: 18px;
            min-width: 0;
        }

        .topbar {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 11px 13px 11px 16px;
        }

        .search {
            flex: 1 1 auto;
            display: flex;
            align-items: center;
            gap: 10px;
            min-width: 0;
            padding: 9px 14px;
            border-radius: 999px;
            background: rgba(255, 255, 255, .72);
            border: 1px solid var(--stroke-soft);
        }

        .search svg {
            flex: 0 0 auto;
            color: var(--muted);
        }

        .search input {
            flex: 1 1 auto;
            min-width: 0;
            border: 0;
            outline: 0;
            background: transparent;
            font-family: inherit;
            font-size: 13.5px;
            color: var(--ink);
        }

        .search input::placeholder {
            color: #b49aa6;
        }

        .user-chip {
            display: flex;
            align-items: center;
            gap: 11px;
            padding: 5px 6px 5px 5px;
            border-radius: 999px;
            background: rgba(255, 255, 255, .74);
            border: 1px solid var(--stroke);
            box-shadow: 0 10px 24px -18px rgba(205, 70, 130, .9);
            flex: 0 0 auto;
        }

        .avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #fff;
            box-shadow: 0 6px 14px -8px rgba(205, 70, 130, .9);
            display: block;
        }

        .user-meta {
            display: flex;
            flex-direction: column;
            line-height: 1.15;
            padding-right: 4px;
        }

        .user-name {
            font-size: 13px;
            font-weight: 700;
            color: var(--ink);
            max-width: 150px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .user-handle {
            font-size: 11px;
            color: var(--muted);
        }

        .logout {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            display: grid;
            place-items: center;
            color: var(--pink-600);
            background: rgba(255, 255, 255, .9);
            border: 1px solid var(--pink-200);
            text-decoration: none;
            transition: transform .18s ease, background .18s ease;
        }

        .logout:hover {
            background: var(--pink-100);
            transform: translateX(1px);
        }

        /* ---------- hero ---------- */
        .hero {
            position: relative;
            overflow: hidden;
            border-radius: 24px;
            padding: 30px 32px;
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 22px;
            background:
                radial-gradient(120% 140% at 88% 8%, rgba(255, 255, 255, .85) 0%, rgba(255, 255, 255, 0) 55%),
                linear-gradient(118deg, #ffd7e7 0%, #ffc0da 42%, #ffb0d1 100%);
            border: 1px solid rgba(255, 255, 255, .9);
            box-shadow: 0 26px 50px -30px rgba(205, 70, 130, .85);
        }

        .hero::after {
            content: "";
            position: absolute;
            width: 320px;
            height: 320px;
            right: -90px;
            top: -140px;
            border-radius: 50%;
            background: rgba(255, 255, 255, .45);
            filter: blur(28px);
        }

        .hero-text {
            position: relative;
            z-index: 1;
            min-width: 0;
        }

        .eyebrow {
            display: inline-block;
            font-size: 10.5px;
            font-weight: 700;
            letter-spacing: 1.8px;
            text-transform: uppercase;
            color: #b3306a;
            background: rgba(255, 255, 255, .6);
            border: 1px solid rgba(255, 255, 255, .9);
            padding: 5px 11px;
            border-radius: 999px;
            margin-bottom: 12px;
        }

        .hero h1 {
            margin: 0;
            font-size: 46px;
            line-height: 1;
            letter-spacing: -2px;
            font-weight: 800;
            color: #46212f;
        }

        .hero-sub {
            margin: 10px 0 0;
            font-size: 13px;
            font-weight: 600;
            color: #7a4159;
        }

        .hero-sub .dot {
            opacity: .5;
            margin: 0 6px;
        }

        .btn-play-all {
            position: relative;
            z-index: 1;
            flex: 0 0 auto;
            display: inline-flex;
            align-items: center;
            gap: 9px;
            padding: 13px 22px;
            border: 0;
            border-radius: 999px;
            cursor: pointer;
            font-family: inherit;
            font-size: 13.5px;
            font-weight: 700;
            color: #fff;
            background: linear-gradient(140deg, var(--pink-400), var(--pink-600));
            box-shadow: 0 16px 30px -14px rgba(230, 58, 128, .95);
            transition: transform .18s ease, box-shadow .18s ease;
        }

        .btn-play-all:hover {
            transform: translateY(-2px);
            box-shadow: 0 20px 34px -14px rgba(230, 58, 128, 1);
        }

        .btn-play-all:active {
            transform: translateY(0);
        }

        /* ---------- track list ---------- */
        .list {
            padding: 14px 14px 20px;
        }

        .track-head, .track {
            display: grid;
            grid-template-columns: 46px minmax(0, 1fr) 132px 78px;
            align-items: center;
            gap: 12px;
        }

        .track-head {
            padding: 6px 12px 12px;
            border-bottom: 1px solid rgba(205, 70, 130, .13);
            font-size: 10.5px;
            font-weight: 700;
            letter-spacing: 1.3px;
            text-transform: uppercase;
            color: var(--muted);
        }

        .ta-c {
            text-align: center;
        }

        .track-head .plays {
            font-size: inherit;
            color: inherit;
        }

        .track {
            padding: 9px 12px;
            border-radius: 15px;
            cursor: pointer;
            transition: background .16s ease, box-shadow .16s ease;
        }

        .track:hover {
            background: rgba(255, 255, 255, .82);
            box-shadow: 0 12px 26px -22px rgba(205, 70, 130, .95);
        }

        .track.is-playing {
            background: linear-gradient(110deg, rgba(255, 255, 255, .95), rgba(255, 216, 232, .85));
            box-shadow: inset 0 0 0 1px rgba(255, 255, 255, .95), 0 14px 28px -24px rgba(205, 70, 130, 1);
        }

        .idx {
            position: relative;
            display: grid;
            place-items: center;
            width: 34px;
            height: 34px;
            font-size: 13px;
            font-weight: 600;
            color: var(--muted);
            font-variant-numeric: tabular-nums;
        }

        .idx .eq {
            position: absolute;
            left: 50%;
            transform: translateX(-50%);
            display: none;
            align-items: flex-end;
            gap: 2px;
            height: 14px;
        }

        .idx .eq i {
            display: block;
            width: 3px;
            border-radius: 2px;
            background: var(--pink-500);
            animation: eq .9s ease-in-out infinite;
        }

        .idx .eq i:nth-child(1) { height: 60%; animation-delay: 0s; }
        .idx .eq i:nth-child(2) { height: 100%; animation-delay: .18s; }
        .idx .eq i:nth-child(3) { height: 45%; animation-delay: .36s; }

        @keyframes eq {
            0%, 100% { transform: scaleY(.45); }
            50% { transform: scaleY(1); }
        }

        .track:hover .idx .num { display: none; }
        .track.is-playing .idx .num { display: none; }
        .track.is-playing .idx .eq { display: flex; }

        .title-cell {
            display: flex;
            align-items: center;
            gap: 13px;
            min-width: 0;
        }

        .cover {
            position: relative;
            width: 46px;
            height: 46px;
            border-radius: 12px;
            flex: 0 0 auto;
            display: grid;
            place-items: center;
            color: rgba(255, 255, 255, .92);
            background: linear-gradient(140deg, #ff9dc2, #e63a80);
            box-shadow: 0 10px 20px -14px rgba(150, 30, 80, .9);
            overflow: hidden;
        }

        .cover::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(150deg, rgba(255, 255, 255, .5), rgba(255, 255, 255, 0) 55%);
        }

        .cover svg {
            position: relative;
            z-index: 1;
        }

        .tracks .track:nth-child(5n+1) .cover { background: linear-gradient(140deg, #ff9dc2, #e63a80); }
        .tracks .track:nth-child(5n+2) .cover { background: linear-gradient(140deg, #ffb3d1, #d94a8d); }
        .tracks .track:nth-child(5n+3) .cover { background: linear-gradient(140deg, #ffc9dd, #ff6fa6); }
        .tracks .track:nth-child(5n+4) .cover { background: linear-gradient(140deg, #ff8fb8, #c93c78); }
        .tracks .track:nth-child(5n+5) .cover { background: linear-gradient(140deg, #ffa8c8, #ef4f92); }

        .names {
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        .song-name {
            font-size: 14.5px;
            font-weight: 650;
            color: var(--ink);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .track.is-playing .song-name {
            color: var(--pink-600);
        }

        .song-sub {
            font-size: 11.5px;
            color: var(--muted);
            margin-top: 2px;
        }

        .plays {
            text-align: center;
            font-size: 13px;
            color: var(--ink-soft);
            font-variant-numeric: tabular-nums;
        }

        .dur {
            text-align: center;
            font-size: 12.5px;
            color: var(--muted);
            font-variant-numeric: tabular-nums;
        }

        .empty {
            padding: 34px 16px 30px;
            text-align: center;
            color: var(--muted);
            font-size: 13.5px;
        }

        .empty strong {
            display: block;
            color: var(--ink);
            font-size: 15px;
            margin-bottom: 6px;
        }

        .msg {
            display: block;
            padding: 0 6px 10px;
            color: #c0275f;
            font-size: 12.5px;
            font-weight: 600;
        }

        /* ---------- player ---------- */
        .player {
            position: fixed;
            left: 18px;
            right: 18px;
            bottom: 18px;
            z-index: 40;
            display: grid;
            grid-template-columns: minmax(170px, 1fr) minmax(260px, 1.5fr) minmax(150px, 1fr);
            align-items: center;
            gap: 16px;
            padding: 12px 20px;
            border-radius: 20px;
            background: rgba(255, 255, 255, .66);
            -webkit-backdrop-filter: blur(26px) saturate(180%);
            backdrop-filter: blur(26px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, .92);
            box-shadow: 0 -10px 40px -22px rgba(205, 70, 130, .9), 0 18px 40px -28px rgba(205, 70, 130, .8);
            max-width: 1464px;
            margin: 0 auto;
        }

        .now {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .now .cover {
            width: 48px;
            height: 48px;
            border-radius: 13px;
        }

        .now-meta {
            min-width: 0;
            display: flex;
            flex-direction: column;
        }

        .now-title {
            font-size: 13.5px;
            font-weight: 700;
            color: var(--ink);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .now-sub {
            font-size: 11.5px;
            color: var(--muted);
            margin-top: 2px;
        }

        .center {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 7px;
            min-width: 0;
            width: 100%;
        }

        .controls {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .ctrl {
            width: 34px;
            height: 34px;
            border: 0;
            border-radius: 50%;
            background: transparent;
            color: var(--ink-soft);
            display: grid;
            place-items: center;
            cursor: pointer;
            transition: background .16s ease, color .16s ease, transform .16s ease;
        }

        .ctrl:hover {
            background: rgba(255, 255, 255, .95);
            color: var(--pink-600);
        }

        .ctrl:active {
            transform: scale(.94);
        }

        .ctrl-play {
            width: 42px;
            height: 42px;
            color: #fff;
            background: linear-gradient(145deg, var(--pink-400), var(--pink-600));
            box-shadow: 0 12px 24px -12px rgba(230, 58, 128, .95);
        }

        .ctrl-play:hover {
            color: #fff;
            background: linear-gradient(145deg, var(--pink-400), var(--pink-600));
            transform: scale(1.05);
        }

        .icon-pause { display: none; }
        .player.is-playing .icon-play { display: none; }
        .player.is-playing .icon-pause { display: block; }

        .progress {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            max-width: 470px;
        }

        .time {
            font-size: 11px;
            color: var(--muted);
            font-variant-numeric: tabular-nums;
            min-width: 34px;
            text-align: center;
        }

        .bar {
            position: relative;
            flex: 1 1 auto;
            height: 5px;
            border-radius: 999px;
            background: rgba(205, 70, 130, .16);
            cursor: pointer;
        }

        .bar::before {
            content: "";
            position: absolute;
            left: 0;
            right: 0;
            top: -7px;
            bottom: -7px;
        }

        .fill {
            position: relative;
            height: 100%;
            width: 0%;
            border-radius: 999px;
            background: linear-gradient(90deg, var(--pink-300), var(--pink-500));
        }

        .fill::after {
            content: "";
            position: absolute;
            right: -5px;
            top: 50%;
            width: 10px;
            height: 10px;
            margin-top: -5px;
            border-radius: 50%;
            background: #fff;
            border: 2px solid var(--pink-500);
            box-shadow: 0 2px 6px rgba(205, 70, 130, .5);
            opacity: 0;
            transition: opacity .16s ease;
        }

        .bar:hover .fill::after {
            opacity: 1;
        }

        .right {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 9px;
            color: var(--muted);
        }

        .vol {
            -webkit-appearance: none;
            appearance: none;
            width: 96px;
            height: 4px;
            border-radius: 999px;
            background: rgba(205, 70, 130, .18);
            outline: none;
            cursor: pointer;
        }

        .vol::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: var(--pink-500);
            border: 2px solid #fff;
            box-shadow: 0 2px 6px rgba(205, 70, 130, .55);
        }

        .vol::-moz-range-thumb {
            width: 12px;
            height: 12px;
            border: 2px solid #fff;
            border-radius: 50%;
            background: var(--pink-500);
        }

        /* ---------- responsive ---------- */
        @media (max-width: 1080px) {
            .app {
                grid-template-columns: 220px minmax(0, 1fr);
            }

            .hero h1 {
                font-size: 38px;
            }
        }

        @media (max-width: 900px) {
            .app {
                grid-template-columns: minmax(0, 1fr);
                padding-bottom: 190px;
            }

            .sidebar {
                display: none;
            }

            .player {
                grid-template-columns: 1fr;
                gap: 10px;
                padding: 12px 16px;
            }

            .now, .right {
                justify-content: center;
            }

            .right {
                display: none;
            }

            .track-head, .track {
                grid-template-columns: 38px minmax(0, 1fr) 62px;
            }

            .track-head .plays, .plays {
                display: none;
            }
        }

        @media (max-width: 620px) {
            .topbar {
                flex-wrap: wrap;
            }

            .search {
                order: 2;
                width: 100%;
                flex: 1 1 100%;
            }

            .hero {
                padding: 22px;
                flex-direction: column;
                align-items: flex-start;
            }

            .hero h1 {
                font-size: 32px;
            }

            .user-meta {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="blobs" aria-hidden="true">
        <span class="blob blob-1"></span>
        <span class="blob blob-2"></span>
        <span class="blob blob-3"></span>
    </div>

    <form id="form1" runat="server">
        <div class="app">

            <!-- ================= SIDEBAR ================= -->
            <aside class="sidebar glass">
                <div class="brand">
                    <span class="brand-logo">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M9 18V5l11-2v13" />
                            <circle cx="6" cy="18" r="3" />
                            <circle cx="17" cy="16" r="3" />
                        </svg>
                    </span>
                    <span class="brand-name">Poli<span>Music</span></span>
                </div>

                <div>
                    <div class="nav-label">Menú</div>
                    <nav class="nav">
                        <span class="nav-item">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M12 3 2 11h3v10h5v-6h4v6h5V11h3z" />
                            </svg>
                            Inicio
                        </span>
                        <span class="nav-item">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round">
                                <circle cx="11" cy="11" r="7" />
                                <path d="m20 20-3.6-3.6" />
                            </svg>
                            Buscar
                        </span>
                        <span class="nav-item is-active">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M4 4h6v6H4zm10 0h6v6h-6zM4 14h6v6H4zm10 0h6v6h-6z" />
                            </svg>
                            Canciones
                        </span>
                    </nav>
                </div>

                <div class="sidebar-card">
                    <h4>Tu biblioteca</h4>
                    <div class="stat"><b><asp:Label ID="lblSidebarCount" runat="server" Text="0"></asp:Label></b> canciones</div>
                    <div class="stat"><b><asp:Label ID="lblTotalPlays" runat="server" Text="0"></asp:Label></b> reproducciones</div>
                </div>
            </aside>

            <!-- ================= MAIN ================= -->
            <div class="main">

                <header class="topbar glass">
                    <div class="search">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
                            <circle cx="11" cy="11" r="7" />
                            <path d="m20 20-3.6-3.6" />
                        </svg>
                        <input type="text" id="txtSearch" placeholder="Buscar en tus canciones…"
                            onkeydown="if (event.keyCode === 13) { return false; }" autocomplete="off" />
                    </div>

                    <div class="user-chip">
                        <asp:Image ID="imgUserPhoto" runat="server" CssClass="avatar" AlternateText="Foto de usuario" />
                        <div class="user-meta">
                            <span class="user-name"><asp:Label ID="lblUserName" runat="server"></asp:Label></span>
                            <span class="user-handle"><asp:Label ID="lblUserHandle" runat="server"></asp:Label></span>
                        </div>
                        <a href="Logout.aspx" class="logout" title="Cerrar sesión">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M15 17l5-5-5-5" />
                                <path d="M20 12H9" />
                                <path d="M12 3H5v18h7" />
                            </svg>
                        </a>
                    </div>
                </header>

                <section class="hero">
                    <div class="hero-text">
                        <span class="eyebrow">Tu biblioteca</span>
                        <h1>Canciones</h1>
                        <p class="hero-sub">
                            <asp:Label ID="lblSongCount" runat="server" Text="0 canciones"></asp:Label>
                            <span class="dot">•</span>
                            PoliMusic
                        </p>
                    </div>
                    <button type="button" class="btn-play-all" id="btnPlayAll">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M8 5v14l11-7z" />
                        </svg>
                        Reproducir todo
                    </button>
                </section>

                <section class="list glass">
                    <asp:Label ID="lblMessage" runat="server" CssClass="msg" Visible="false"></asp:Label>

                    <div class="track-head">
                        <span class="ta-c">#</span>
                        <span>Título</span>
                        <span class="ta-c plays">Reproducciones</span>
                        <span class="ta-c">Duración</span>
                    </div>

                    <div class="tracks">
                        <asp:Repeater ID="rptSongs" runat="server">
                            <ItemTemplate>
                                <div class="track" data-src='<%# Eval("SONG_URL") %>' data-title='<%# Eval("SONG_TITLE") %>' data-id='<%# Eval("ID_SONG") %>'>
                                    <div class="idx">
                                        <span class="num"><%# Container.ItemIndex + 1 %></span>
                                        <span class="eq"><i></i><i></i><i></i></span>
                                    </div>
                                    <div class="title-cell">
                                        <div class="cover">
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M9 18V5l11-2v13" />
                                                <circle cx="6" cy="18" r="3" />
                                                <circle cx="17" cy="16" r="3" />
                                            </svg>
                                        </div>
                                        <div class="names">
                                            <span class="song-name"><%# Eval("SONG_TITLE") %></span>
                                            <span class="song-sub">PoliMusic</span>
                                        </div>
                                    </div>
                                    <div class="plays"><%# Eval("PLAYS") %></div>
                                    <div class="dur" data-dur>--:--</div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                        <strong>Todavía no hay canciones</strong>
                        Cuando se registren canciones en la biblioteca aparecerán aquí.
                    </asp:Panel>
                </section>
            </div>
        </div>

        <!-- ================= PLAYER ================= -->
        <div class="player" id="playerBar">
            <div class="now">
                <div class="cover" id="playerCover">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M9 18V5l11-2v13" />
                        <circle cx="6" cy="18" r="3" />
                        <circle cx="17" cy="16" r="3" />
                    </svg>
                </div>
                <div class="now-meta">
                    <span class="now-title" id="playerTitle">Selecciona una canción</span>
                    <span class="now-sub" id="playerSub">PoliMusic</span>
                </div>
            </div>

            <div class="center">
                <div class="controls">
                    <button type="button" class="ctrl" id="btnPrev" title="Anterior">
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M6 6h2v12H6zm3.5 6 8.5 6V6z" />
                        </svg>
                    </button>
                    <button type="button" class="ctrl ctrl-play" id="btnPlayPause" title="Reproducir">
                        <svg class="icon-play" width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M8 5v14l11-7z" />
                        </svg>
                        <svg class="icon-pause" width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M7 5h4v14H7zm6 0h4v14h-4z" />
                        </svg>
                    </button>
                    <button type="button" class="ctrl" id="btnNext" title="Siguiente">
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M16 6h2v12h-2zM6 18l8.5-6L6 6z" />
                        </svg>
                    </button>
                </div>
                <div class="progress">
                    <span class="time" id="timeCurrent">0:00</span>
                    <div class="bar" id="progressBar">
                        <div class="fill" id="progressFill"></div>
                    </div>
                    <span class="time" id="timeTotal">0:00</span>
                </div>
            </div>

            <div class="right">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M3 9v6h4l5 4V5L7 9H3zm13.5 3a4.5 4.5 0 0 0-2.5-4v8a4.5 4.5 0 0 0 2.5-4z" />
                </svg>
                <input type="range" class="vol" id="volSlider" min="0" max="1" step="0.01" value="0.85" />
            </div>
        </div>

        <audio id="audioPlayer" preload="metadata"></audio>
    </form>

    <script type="text/javascript">
        (function () {
            var audio = document.getElementById('audioPlayer');
            var playerBar = document.getElementById('playerBar');
            var trackList = Array.prototype.slice.call(document.querySelectorAll('.tracks .track'));
            var playerTitle = document.getElementById('playerTitle');
            var playerSub = document.getElementById('playerSub');
            var playerCover = document.getElementById('playerCover');
            var btnPlayPause = document.getElementById('btnPlayPause');
            var btnPrev = document.getElementById('btnPrev');
            var btnNext = document.getElementById('btnNext');
            var btnPlayAll = document.getElementById('btnPlayAll');
            var progressBar = document.getElementById('progressBar');
            var progressFill = document.getElementById('progressFill');
            var timeCurrent = document.getElementById('timeCurrent');
            var timeTotal = document.getElementById('timeTotal');
            var volSlider = document.getElementById('volSlider');
            var txtSearch = document.getElementById('txtSearch');
            var currentIndex = -1;

            function formatTime(seconds) {
                if (!isFinite(seconds) || seconds < 0) { return '0:00'; }
                var total = Math.floor(seconds);
                var minutes = Math.floor(total / 60);
                var rest = total % 60;
                return minutes + ':' + (rest < 10 ? '0' + rest : rest);
            }

            function setActiveRow(index) {
                for (var i = 0; i < trackList.length; i++) {
                    if (i === index) { trackList[i].className = 'track is-playing'; }
                    else { trackList[i].className = 'track'; }
                }
            }

            function loadTrack(index, autoplay) {
                if (trackList.length === 0) { return; }
                if (index < 0) { index = trackList.length - 1; }
                if (index >= trackList.length) { index = 0; }

                currentIndex = index;
                var row = trackList[index];
                audio.src = row.getAttribute('data-src');
                playerTitle.textContent = row.getAttribute('data-title');
                playerSub.textContent = 'PoliMusic';
                var rowCover = row.querySelector('.cover');
                if (rowCover && playerCover) {
                    playerCover.style.backgroundImage = window.getComputedStyle(rowCover).backgroundImage;
                }
                setActiveRow(index);
                progressFill.style.width = '0%';
                timeCurrent.textContent = '0:00';

                if (autoplay) {
                    audio.play();
                }
            }

            function syncPlayState() {
                if (audio.paused) {
                    playerBar.className = 'player';
                    btnPlayPause.title = 'Reproducir';
                } else {
                    playerBar.className = 'player is-playing';
                    btnPlayPause.title = 'Pausar';
                }
            }

            function togglePlay() {
                if (currentIndex === -1) {
                    if (trackList.length > 0) { loadTrack(0, true); }
                    return;
                }
                if (audio.paused) { audio.play(); } else { audio.pause(); }
            }

            for (var i = 0; i < trackList.length; i++) {
                (function (index) {
                    var row = trackList[index];
                    row.addEventListener('click', function () {
                        if (currentIndex === index && !audio.paused) {
                            audio.pause();
                        } else if (currentIndex === index) {
                            audio.play();
                        } else {
                            loadTrack(index, true);
                        }
                    });

                    // Pre-carga solo los metadatos para mostrar la duración real.
                    var probe = new Audio();
                    probe.preload = 'metadata';
                    probe.src = row.getAttribute('data-src');
                    probe.addEventListener('loadedmetadata', function () {
                        var durCell = row.querySelector('[data-dur]');
                        if (durCell && isFinite(probe.duration)) {
                            durCell.textContent = formatTime(probe.duration);
                        }
                    });
                })(i);
            }

            btnPlayPause.addEventListener('click', togglePlay);

            btnPlayAll.addEventListener('click', function () {
                if (trackList.length > 0) { loadTrack(0, true); }
            });

            btnNext.addEventListener('click', function () { loadTrack(currentIndex + 1, true); });
            btnPrev.addEventListener('click', function () {
                if (audio.currentTime > 3) { audio.currentTime = 0; return; }
                loadTrack(currentIndex - 1, true);
            });

            audio.addEventListener('timeupdate', function () {
                var duration = audio.duration;
                if (isFinite(duration) && duration > 0) {
                    progressFill.style.width = ((audio.currentTime / duration) * 100) + '%';
                }
                timeCurrent.textContent = formatTime(audio.currentTime);
            });

            audio.addEventListener('loadedmetadata', function () {
                timeTotal.textContent = formatTime(audio.duration);
            });

            audio.addEventListener('play', syncPlayState);
            audio.addEventListener('pause', syncPlayState);

            audio.addEventListener('ended', function () {
                if (currentIndex < trackList.length - 1) {
                    loadTrack(currentIndex + 1, true);
                } else {
                    audio.pause();
                    audio.currentTime = 0;
                    syncPlayState();
                }
            });

            function seekFromEvent(event) {
                var duration = audio.duration;
                if (!isFinite(duration) || duration <= 0) { return; }
                var rect = progressBar.getBoundingClientRect();
                var ratio = (event.clientX - rect.left) / rect.width;
                if (ratio < 0) { ratio = 0; }
                if (ratio > 1) { ratio = 1; }
                audio.currentTime = ratio * duration;
                progressFill.style.width = (ratio * 100) + '%';
            }

            progressBar.addEventListener('mousedown', function (event) {
                seekFromEvent(event);
                var onMove = function (moveEvent) { seekFromEvent(moveEvent); };
                var onUp = function () {
                    document.removeEventListener('mousemove', onMove);
                    document.removeEventListener('mouseup', onUp);
                };
                document.addEventListener('mousemove', onMove);
                document.addEventListener('mouseup', onUp);
            });

            volSlider.addEventListener('input', function () {
                audio.volume = parseFloat(volSlider.value);
            });
            audio.volume = parseFloat(volSlider.value);

            if (txtSearch) {
                txtSearch.addEventListener('input', function () {
                    var term = txtSearch.value.toLowerCase().trim();
                    for (var j = 0; j < trackList.length; j++) {
                        var title = (trackList[j].getAttribute('data-title') || '').toLowerCase();
                        trackList[j].style.display = (term === '' || title.indexOf(term) !== -1) ? '' : 'none';
                    }
                });
            }

            document.addEventListener('keydown', function (event) {
                var tag = (event.target && event.target.tagName) ? event.target.tagName.toLowerCase() : '';
                if (tag === 'input' || tag === 'textarea') { return; }
                if (event.keyCode === 32) {
                    event.preventDefault();
                    togglePlay();
                }
            });

            syncPlayState();
        })();
    </script>
</body>
</html>
