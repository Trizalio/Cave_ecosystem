package Game
{
    import flash.display.MovieClip;
	import flash.display.Graphics;
	import flash.display.BitmapData;
    public class Cell
    {
		public static var c_DurabilityMax:Number = 10;
		public var m_Durability:Number;
		public var m_WaterLevel:Number;
		
		public var m_Illumination:Number;
		
		public var m_Wall:Boolean;
		public var m_Inner:Boolean;
		
		public var m_Damaged:Boolean;
		
		public var m_X:Number;
		public var m_Y:Number;
		
		public var m_NeighborTop:Cell;
		public var m_NeighborLeft:Cell;
		public var m_NeighborBottom:Cell;
		public var m_NeighborRight:Cell;
		
		public var m_ChangedAfterDraw:Boolean = true;
		
		public var m_DamageResistance:Number;
		
		/*private var m_Neighbors:Array = new Array(3); 
		private function initArray():void
		{
			for(var i:int = 0; i < 3; ++i)
			{
				m_Neighbors[i] = new Array(3);
			}
		}
		public function setNeighbor(i, j, Neighbor):void
		{
			if(i >= -1 && i <= 1 && j >= -1 && j <= 1)
			{
				m_Neighbors[i][j] = Neighbor;
			}
		}
		public function getNeighbor(i, j):Cell
		{
			if(i >= -1 && i <= 1 && j >= -1 && j <= 1)
			{
				return m_Neighbors[i][j];
			}
			return null;
		}*/		
		public function Cell(MyX, MyY)
		{
			//trace("Cell");
			//initArray();
			m_X = MyX;
			m_Y = MyY;
			m_Wall = true;
			m_Inner = true;
			m_Illumination = 0.5;
			m_WaterLevel = 0;
			m_Durability = Math.random()*c_DurabilityMax;
			m_Damaged = false;
			m_DamageResistance = 0;
			
			//trace("!Cell");
		}
		
		public function takeDirectDamage(Damage:Number):Boolean
		{
			m_ChangedAfterDraw = true;
			m_Damaged = true;
			if(!m_Wall){return true;}
			m_Durability -= Damage;
			if(m_Durability <= 0)
			{
				//m_Durability = 0;
				breakWall();
				return true;
			}
			return false;
		}
		
		public function isDamaged():Boolean
		{
			return m_Damaged;
		}
		public function takeDamage(Damage:Number, Sharpness:Number):Boolean
		{
			return takeDirectDamage(Damage);
		}
		public function isWall():Boolean
		{
			return m_Wall;
		}
		public function isInner():Boolean
		{
			return m_Inner;
		}
		public function breakWall():void
		{
			m_Wall = false;
			m_Durability = 0;
			m_ChangedAfterDraw = true;
			if(m_Inner)
			{
				return;
			}
			if(m_NeighborTop)
			{
				m_NeighborTop.makeOuter();
			}
			if(m_NeighborLeft)
			{
				m_NeighborLeft.makeOuter();
			}
			if(m_NeighborBottom)
			{
				m_NeighborBottom.makeOuter();
			}
			if(m_NeighborRight)
			{
				m_NeighborRight.makeOuter();
			}
		}
		public function makeOuter():void
		{
			m_Inner = false;
			m_ChangedAfterDraw = true;
		}
		public function makeInner():void
		{
			m_Inner = true;
			m_ChangedAfterDraw = true;
		}
		private function drawRectangleAt(Target:Graphics, Size:Number, RecColor:uint, RecAlpha:Number):void
		{
			Target.beginFill(RecColor, RecAlpha);
			Target.moveTo(m_X * Size, m_Y * Size);
			Target.lineTo((m_X + 1) * Size, m_Y * Size);
			Target.lineTo((m_X + 1) * Size, (m_Y + 1) * Size);
			Target.lineTo(m_X * Size, (m_Y + 1) * Size);
			Target.lineTo(m_X * Size, m_Y * Size);
		}
		public function drawAtBitmapData(Target:BitmapData):void
		{
			var CurRed:int = 255;
			var CurGreen:int = 255;
			var CurBlue:int = 255;
			if(m_Wall)
			{
/*				if(m_Durability < 0)
				{
					trace("problems");
				}*/
				CurRed *= m_Durability/10;
				CurBlue *= m_Durability/10;
			}
			else
			{
/*				if(m_Durability > 0)
				{
					trace("problems");
				}*/
				CurGreen *= -m_Durability/10;
				CurBlue *= -m_Durability/10;
			}
			//trace(CurRed + " " + CurGreen + " " + CurBlue)
			var CurColor:uint = CurRed << 16 | CurGreen << 8 | CurBlue;
			Target.setPixel(m_X, m_Y, CurColor); 
		}
		public function drawAt(Target:MovieClip, Size:Number):void
		{
			if(!Target)
			{
				return;
			}
			if(m_ChangedAfterDraw)
			{
				drawRectangleAt(Target.graphics, Size, 0xFFFFFF, 1);
				if(m_Wall)
				{
					//drawRectangleAt(Target.graphics, Size, 0x00FF00, m_Durability/10);
				}
				else
				{
					//drawRectangleAt(Target.graphics, Size, 0xFF0000, -m_Durability/10);
				}
					
				// Draw water
				if(m_WaterLevel)
				{
					//drawRectangleAt(Target.graphics, Size, 0x0000FF, m_WaterLevel);
				}
				
				// Draw shadow
				if(isInner())
				{
					//drawRectangleAt(Target.graphics, Size, 0x000000, m_Illumination);
				}
			}
			m_ChangedAfterDraw = false;
		}
    }
}