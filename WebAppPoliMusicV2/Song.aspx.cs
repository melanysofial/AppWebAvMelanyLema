using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString =
            ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session[Util.Constants.USER] == null)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!Page.IsPostBack)
            {
                LoadUser((Entities.User)Session[Util.Constants.USER]);
                LoadSongs();
            }
        }

        /// <summary>
        /// Show the authenticated user data on the header.
        /// </summary>
        private void LoadUser(Entities.User user)
        {
            lblUserName.Text = Server.HtmlEncode(user.UserName);
            lblUserHandle.Text = Server.HtmlEncode("@" + user.UserName);
            string strPhoto = string.IsNullOrEmpty(user.Photo) ? "~/userImages/default.jpg" : user.Photo;
            imgUserPhoto.ImageUrl = ResolveUrl(strPhoto);
            imgUserPhoto.AlternateText = user.UserName;
        }

        /// <summary>
        /// List every song of TBL_SONG (read only, no editing from this page).
        /// </summary>
        private void LoadSongs()
        {
            try
            {
                DataTable dtSongs = new BLL.Song(strConnString).Read();
                if (dtSongs == null)
                {
                    dtSongs = new DataTable();
                }

                // Resolve the "~/songFiles/..." stored path to a URL the browser can play.
                if (!dtSongs.Columns.Contains("SONG_URL"))
                {
                    dtSongs.Columns.Add("SONG_URL", typeof(string));
                }
                // Encoded name, safe to print as text and inside the data-title attribute.
                if (!dtSongs.Columns.Contains("SONG_TITLE"))
                {
                    dtSongs.Columns.Add("SONG_TITLE", typeof(string));
                }
                int totalPlays = 0;
                foreach (DataRow rowSong in dtSongs.Rows)
                {
                    rowSong["SONG_URL"] = ResolveUrl(rowSong["SONG_PATH"].ToString());
                    rowSong["SONG_TITLE"] = Server.HtmlEncode(rowSong["SONG_NAME"].ToString()).Replace("'", "&#39;");
                    if (rowSong["PLAYS"] != DBNull.Value)
                    {
                        totalPlays += Convert.ToInt32(rowSong["PLAYS"]);
                    }
                }

                rptSongs.DataSource = dtSongs;
                rptSongs.DataBind();

                int totalSongs = dtSongs.Rows.Count;
                lblSongCount.Text = (totalSongs == 1) ? "1 canción" : totalSongs + " canciones";
                lblSidebarCount.Text = totalSongs.ToString();
                lblTotalPlays.Text = totalPlays.ToString();
                pnlEmpty.Visible = (totalSongs == 0);
                lblMessage.Visible = false;
            }
            catch (Exception ex)
            {
                pnlEmpty.Visible = false;
                lblMessage.Text = "No se pudo cargar la lista de canciones: " + Server.HtmlEncode(ex.Message);
                lblMessage.Visible = true;
            }
        }
    }
}
