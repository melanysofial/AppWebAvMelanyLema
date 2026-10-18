<%
' ============================================================
'  Fila reutilizable de la lista de canciones
' ============================================================
Function TrackRowHtml(ByVal n, ByVal songId, ByVal title, ByVal artist, ByVal src, _
                      ByVal cover, ByVal album, ByVal albumId, ByVal plays, ByVal showAlbum)
    Dim html, cls, albumCell, extra
    cls = "track-row"
    albumCell = ""
    extra = ""

    If showAlbum Then
        If CLng(albumId) > 0 Then
            albumCell = "<div class=""track-album""><a href=""" & Url("album.asp?id=" & albumId) & """>" & H(album) & "</a></div>"
        Else
            albumCell = "<div class=""track-album"">—</div>"
        End If
    Else
        cls = cls & " no-album"
    End If

    If src = "" Then
        cls = cls & " is-disabled"
        extra = " title=""Archivo de audio no disponible"""
    End If

    html = "<div class=""" & cls & """ data-track data-song-id=""" & A(songId) & """" & _
        " data-title=""" & A(title) & """ data-artist=""" & A(artist) & """" & _
        " data-src=""" & A(src) & """ data-cover=""" & A(cover) & """" & _
        " data-album=""" & A(album) & """" & extra & ">"
    html = html & "<div class=""track-index""><span class=""idx"">" & n & "</span>"
    html = html & "<button class=""row-play"" type=""button"" data-play aria-label=""Reproducir " & A(title) & """>"
    html = html & "<svg class=""icon icon-fill"" viewBox=""0 0 24 24""><use href=""#i-play""></use></svg></button></div>"
    html = html & "<div class=""track-name""><strong>" & H(title) & "</strong><span class=""track-sub"">" & H(artist) & "</span></div>"
    html = html & albumCell
    html = html & "<div class=""track-plays"">" & Num(plays) & "</div>"
    html = html & "<div class=""track-actions""></div>"
    html = html & "</div>"
    TrackRowHtml = html
End Function
%>
