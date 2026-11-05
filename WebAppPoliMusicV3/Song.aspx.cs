using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV3
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                // Verificar si el usuario esta autenticado (sesion activa)
                if (Session[EntityLayer.PoliMusicV3.Util.Constants.USER] == null)
                {
                    Response.Redirect("~/Login", true);
                }

                // Cargar el nombre del usuario autenticado
                EntityLayer.PoliMusicV3.User user = (EntityLayer.PoliMusicV3.User)Session[EntityLayer.PoliMusicV3.Util.Constants.USER];
                lblUserName.Text = user.UserName;

                // Cargar el listado de canciones
                LoadSongs();
            }
        }

        /// <summary>
        /// Consulta las canciones desde la base de datos via BLL y las enlaza al GridView.
        /// </summary>
        private void LoadSongs()
        {
            try
            {
                DataTable dtSongs = new BLL.PoliMusicV3.Song(strConnString).Read();

                if (dtSongs != null && dtSongs.Rows.Count > 0)
                {
                    // Agregar columna calculada con la URL de la cancion
                    string songFolderPath = ConfigurationManager.AppSettings["songFolderPath"];
                    if (string.IsNullOrEmpty(songFolderPath))
                    {
                        songFolderPath = "~/songFiles/";
                    }

                    dtSongs.Columns.Add("SONG_URL", typeof(string));
                    dtSongs.Columns.Add("SONG_TITLE", typeof(string));

                    foreach (DataRow row in dtSongs.Rows)
                    {
                        string songName = row["SONG_NAME"].ToString();
                        string songPath = row["SONG_PATH"].ToString();

                        // Construir la URL relativa de la cancion
                        string songUrl = ResolveUrl("~/songFiles/" + System.IO.Path.GetFileName(songPath));
                        row["SONG_URL"] = songUrl;
                        row["SONG_TITLE"] = songName;
                    }

                    gvSongs.DataSource = dtSongs;
                    gvSongs.DataBind();
                    lblSongCount.Text = dtSongs.Rows.Count.ToString();
                }
                else
                {
                    gvSongs.DataSource = null;
                    gvSongs.DataBind();
                    lblSongCount.Text = "0";
                }
            }
            catch (Exception ex)
            {
                // En caso de error, mostrar mensaje en la pagina
                lblSongCount.Text = "0";
                System.Diagnostics.Debug.WriteLine("Error al cargar canciones: " + ex.Message);
            }
        }

        /// <summary>
        /// Maneja el evento de clic en el boton Reproducir del GridView.
        /// Recibe el ID, nombre y ruta de la cancion y la carga en el reproductor.
        /// </summary>
        protected void gvSongs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "PlaySong")
            {
                string[] args = e.CommandArgument.ToString().Split(';');
                if (args.Length >= 3)
                {
                    int songId = Convert.ToInt32(args[0]);
                    string songName = args[1];
                    string songPath = args[2];

                    // Construir la URL de la cancion
                    string songUrl = ResolveUrl("~/songFiles/" + System.IO.Path.GetFileName(songPath));

                    // Pasar la informacion al cliente via hidden fields
                    hfSongUrl.Value = songUrl;
                    hfSongTitle.Value = songName;

                    // Incrementar el contador de reproducciones
                    try
                    {
                        new BLL.PoliMusicV3.Song(strConnString).IncrementPlays(songId);
                    }
                    catch
                    {
                        // Si falla el incremento, continuar con la reproduccion
                    }
                }
            }
        }
    }
}
