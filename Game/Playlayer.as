package Game
{
	import Game.Map;
    import flash.display.MovieClip;
	import flash.events.Event; 
	import flash.events.MouseEvent; 
    public class Playlayer extends MovieClip
    {
		private var m_Map:Game.Map;
		private var m_FramesSkipped:int = 0;
		private var m_MapGenerated:Boolean = false;
		private var m_MousePosition_X:int;
		private var m_MousePosition_Y:int;
        public function Playlayer()
        {
			trace("Playlayer");
			m_Map = new Game.Map();
			this.addChild(m_Map);
			m_Map.x = 0;
			m_Map.y = 0;
			trace("!Playlayer");
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener( MouseEvent.MOUSE_DOWN, beginDrag );
			
        }
		public function onEnterFrame(event:Event)
		{
			if(!m_MapGenerated)
			{
				m_MapGenerated = m_Map.generationTick();
			}
		}
		
		function beginDrag( e:MouseEvent )
		{
			stage.addEventListener( MouseEvent.MOUSE_MOVE, drag );
			stage.addEventListener( MouseEvent.MOUSE_UP, endDrag );
			//stage.addEventListener( MouseEvent.DEACTIVATE, endDrag );
			stage.addEventListener( Event.MOUSE_LEAVE, endDrag );
			//stage.addEventListener( Event.REMOVED_FROM_STAGE, stageEndDrag );
			m_MousePosition_X = e.stageX - m_Map.x;
			m_MousePosition_Y = e.stageY - m_Map.y;
		  //trigger beginDrag event
		}
		function drag( e:MouseEvent )
		{
			m_Map.x = e.stageX - m_MousePosition_X;
			m_Map.y = e.stageY - m_MousePosition_Y;
		  //trigger drag event
		}
		function endDrag( e:Event )
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, drag );
			stage.removeEventListener( MouseEvent.MOUSE_UP, endDrag );
			//stage.removeEventListener( MouseEvent.DEACTIVATE, endDrag );
			stage.removeEventListener( Event.MOUSE_LEAVE, endDrag );
			//stage.removeEventListener( Event.REMOVED_FROM_STAGE, stageEndDrag );
		
		  //trigger endDrag event
		}
    }
}