package Game
{
	import Game.Map;
    import flash.display.MovieClip;
    public class Playlayer extends MovieClip
    {
		private var m_Map:Game.Map;
        public function Playlayer()
        {
             trace("Playlayer");
			 m_Map = new Game.Map();
			 this.addChild(m_Map);
             trace("!Playlayer");
        }
    }
}