package Game
{
	import Game.Playlayer;
    import flash.display.MovieClip;
    public class Main extends MovieClip
    {
		private var m_Playlayer:Game.Playlayer;
        public function Main()
        {
             trace("Main")
			 m_Playlayer = new Game.Playlayer();
			 this.addChild(m_Playlayer);
             trace("!Main");
        }
    }
}