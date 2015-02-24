package Game
{
	import Game.Cell;
	import Game.Utils;
    import flash.display.MovieClip;
    import flash.utils.getTimer;
	import flash.display.Bitmap; 
	import flash.display.BitmapData; 
    public class Map extends MovieClip
    {
		// Constants
		private static var c_CellSize:int = 10;
		private static var c_MapSize:int = 300;
		private static var c_MountainRandomFactor:int = c_MapSize/40;

		
		// Outer charasteristics
		private var m_Scale:Number = 100/c_MapSize;
		
		private var m_Drawlayer:flash.display.MovieClip;
		
		private var bitmapDataObject1:BitmapData = new BitmapData(c_MapSize, c_MapSize, false, 0x006666FF); 
		private var bitmapImage:Bitmap = new Bitmap(bitmapDataObject1); 
		
		private var m_MapData:Array = new Array(c_MapSize); 
		
		private var m_GenerationStep:int = 0;
		private var m_NextSourceX:int = 0;
		private var m_NextSourceY:int = 0;
		
		private var m_TicksSkipped:int = 0;
		
		
		///////////////////////////////////////////////////////////////////////////////////
        public function Map()
        {
            //trace("Map");
			//generateArray();
			m_GenerationStep = 0;
			m_Drawlayer = new flash.display.MovieClip();
			this.addChild(m_Drawlayer);
			addChild(bitmapImage); 
			//generateMountain();
			//createCave();
			//checkReachability();
			//renderMap();
            //trace("!Map");
        }
		///////////////////////////////////////////////////////////////////////////////////
		public function generationTickPreDivider()
		{
			generationTick();
			if(++m_TicksSkipped > 2)
			{
				m_TicksSkipped = 0;
				generationTick();
			}
//			destroyTick()
		}
		///////////////////////////////////////////////////////////////////////////////////
		private var m_tmpHolder:int = 0;
		public function generationTick():Boolean
		{
            trace("generationStep " + m_GenerationStep);
			var StartTime:uint = getTimer();
			var Cicles:int = 0;
			while(true)
			{
				var CurrentTime:uint = getTimer();
				var DeltaTime = CurrentTime - StartTime;
				if(DeltaTime > 10)
				{
					break;
				}
				while(!renderChangedTick())
				{						
					DeltaTime = CurrentTime - StartTime;
					if(DeltaTime > 10)
					{
						break;
					}
				}
				if(m_GenerationStep == 0)
				{
					if(generateArrayTick())
					{
						m_GenerationStep = 1;
					}
				}
				else if(m_GenerationStep == 1)
				{
					if(generateMountainTick())
					{
						m_GenerationStep = 2;
					}
				}
				else if(m_GenerationStep == 2)
				{
					if(m_ConnectedToOuter)
					{
						if(createNextSource())
						{
							m_GenerationStep = 3;
						}
					} 
					else 
					{
						destroyTick();
					}
				}
				else if(m_GenerationStep == 3)
				{
					makeInnerTick();
					m_GenerationStep = 4;
				}
				else if(m_GenerationStep == 4)
				{
					checkReachabilityTick();
					m_GenerationStep = 5;
				}
				else if(m_GenerationStep == 5)
				{
					return true;
				}
				++Cicles;
			}
			trace(Cicles);
			
			//if(m_GenerationStep != 0 && m_GenerationStep != 1 && m_GenerationStep != 2)
				//renderMap();
            ////trace("!generationStep");
			return false;
		}
//		public function 
		///////////////////////////////////////////////////////////////////////////////////
        public function createNextSource():Boolean
        {
            ////trace("createNextSource");
			var Divider:uint = c_MapSize/20;
			var Step:uint = (c_MapSize-1)/Divider;
			while(true)
			{
				if(m_NextSourceX < c_MapSize)
				{
					m_NextSourceY += Step;
					if(m_NextSourceY > c_MapSize)
					{
						m_NextSourceY = 0;
						m_NextSourceX += Step;
						if(m_NextSourceX > c_MapSize)
						{
							//trace("!createNextSource");
							return true;
						}
					}
					//trace("here?");
					//trace(m_NextSourceX + ", " + m_NextSourceY);
					if(m_MapData[m_NextSourceX][m_NextSourceY].isWall())
					{
						//trace("here!");
						m_ReachableCells.length = 0;
						m_DamagedCells.length = 0;
						m_ReachableCells.push(m_MapData[m_NextSourceX][m_NextSourceY]);
						m_DamagedCells.push(m_MapData[m_NextSourceX][m_NextSourceY]);
						//m_ToRenderCells.push(m_MapData[m_NextSourceX][m_NextSourceY]);
						m_ConnectedToOuter = false;
						//createNewSource(m_MapData[m_NextSourceX][m_NextSourceY]);
						//renderMap();
						return false;
					}
					//trace("!createNextSource");
				}
			}
			return true;
        }
		
		
		///////////////////////////////////////////////////////////////////////////////////
		
		private var m_ReachableCells:Array = new Array();
		private var m_DamagedCells:Array = new Array();
		private var m_ConnectedToOuter:Boolean = true;
		private function destroyTick():void
		{
			//trace("destroyTick");
			//for(var i:int = 0; i < c_MapSize*c_MapSize/50 || !m_ConnectedToOuter; ++i)
			//{
            	////trace("looking for target");
				var MinDurability = Cell.c_DurabilityMax;
				var TargetCellNumber:int = -1;
				for(var j:int = 0; j < m_ReachableCells.length; ++j)
				{
					var CurCell:Cell = m_ReachableCells[j];
					if(MinDurability > CurCell.m_Durability)
					{
						if(CurCell.m_Durability <= 0)
						{
							var CurNeighbor0:Cell;
							for(var s:int = 0; s < 4; ++s)
							{
								if(s == 0)
								{
									CurNeighbor0 = CurCell.m_NeighborLeft;
								}
								else if(s == 1)
								{
									CurNeighbor0 = CurCell.m_NeighborRight;
								}
								else if(s == 2)
								{
									CurNeighbor0 = CurCell.m_NeighborTop;
								}
								else if(s == 3)
								{
									CurNeighbor0 = CurCell.m_NeighborBottom;
								}
								if(CurNeighbor0 && CurNeighbor0.isWall())
								{
									if(m_ReachableCells.indexOf(CurNeighbor0) < 0 && m_DamagedCells.indexOf(CurNeighbor0) < 0)
									{
										m_ReachableCells.push(CurNeighbor0);
										m_DamagedCells.push(CurNeighbor0);
										//m_ToRenderCells.push(CurNeighbor0);
									}
								}
							}
							if(!CurCell.isInner())
							{
								m_ConnectedToOuter = true;
							}
							m_ReachableCells.splice(j, 1);
							--j;
							
						}
						else
						{
							MinDurability = CurCell.m_Durability;
							TargetCellNumber = j;
						}
					}
				}
				
            	////trace("checking target");
				if(TargetCellNumber >= 0)
				{
            		////trace("target found");
					var TargetCell:Cell = m_ReachableCells[TargetCellNumber];
					var Damage:Number = TargetCell.m_Durability;
					var SideDamage:Number = Damage/4;
					var CurNeighbor:Cell;
					var NeighborsDamaged:int = 0;
					TargetCell.takeDamage(Damage, 0);
					for(var k:int = 0; k < 4; ++k)
					{
						if(k == 0)
						{
							CurNeighbor = TargetCell.m_NeighborLeft;
						}
						else if(k == 1)
						{
							CurNeighbor = TargetCell.m_NeighborRight;
						}
						else if(k == 2)
						{
							CurNeighbor = TargetCell.m_NeighborTop;
						}
						else if(k == 3)
						{
							CurNeighbor = TargetCell.m_NeighborBottom;
						}
						if(CurNeighbor && CurNeighbor.isWall())
						{
							if(m_ReachableCells.indexOf(CurNeighbor) < 0)
							{
								m_ReachableCells.push(CurNeighbor);
								m_DamagedCells.push(CurNeighbor);
								//m_ToRenderCells.push(CurNeighbor);
							}
							CurNeighbor.takeDamage(SideDamage, 0);
						}
					}
				}
				if(m_ConnectedToOuter)
				{
					for(var z:int  = 0; z < m_DamagedCells.length; ++z)
					{
						m_DamagedCells[z].makeOuter();
						m_ToRenderCells.push(m_DamagedCells[z]);
					}
				}
			//}
			//trace("!destroyTick");
		}
		///////////////////////////////////////////////////////////////////////////////////
		private var makeInner_i:int = 0;
		private var makeInner_j:int = 0;
		private function makeInnerTick()
		{
            //trace("makeInnerTick");
			
            //trace("generateMountainTick");
			if(makeInner_i < c_MapSize)
			{
				if(makeInner_j < c_MapSize)
				{
					var CurCell:Cell = m_MapData[makeInner_i][makeInner_j];
					m_ToRenderCells.push(CurCell);
					CurCell.makeInner();
					++makeInner_j;
				}
				else
				{
					makeInner_j = 0;
					++makeInner_i;
				}
				
				return false;
			}
			else
			{
				return true;
			}
            //trace("!makeInnerTick");
		}
		private var checkReachability_i:int = 0;
		private var checkReachabilityNeighborCells:Array = new Array();
		private function checkReachabilityTick()
		{
            //trace("checkReachabilityTick");
			if(checkReachability_i == 0)
			{
				checkReachabilityNeighborCells.push(m_MapData[0][0]);
			}
			if(checkReachabilityNeighborCells.length > 0)
			{
				var CurrentCell = checkReachabilityNeighborCells[0];
				CurrentCell.makeOuter();
				if(!CurrentCell.isWall())
				{
					m_ToRenderCells.push(CurrentCell);
					CurrentCell.makeOuter();
					var CurNeighbor0:Cell;
					for(var s:int = 0; s < 4; ++s)
					{
						if(s == 0)
						{
							CurNeighbor0 = CurrentCell.m_NeighborLeft;
						}
						else if(s == 1)
						{
							CurNeighbor0 = CurrentCell.m_NeighborRight;
						}
						else if(s == 2)
						{
							CurNeighbor0 = CurrentCell.m_NeighborTop;
						}
						else if(s == 3)
						{
							CurNeighbor0 = CurrentCell.m_NeighborBottom;
						}
						if(CurNeighbor0 && CurNeighbor0.isInner() && checkReachabilityNeighborCells.indexOf(CurNeighbor0) < 0)
						{
							checkReachabilityNeighborCells.push(CurNeighbor0);
						}
					}
				}
				checkReachabilityNeighborCells.splice(0, 1);
			
				++checkReachability_i;
				return false;
			}
			else
			{
				return true;
			}
            //trace("!checkReachabilityTick");
		}
		///////////////////////////////////////////////////////////////////////////////////
		private var generateMountain_i:int = 0;
		private var generateMountain_j:int = 0;
		private function generateMountainTick()
		{
            //trace("generateMountainTick");
			if(generateMountain_i < c_MapSize)
			{
				if(generateMountain_j < c_MapSize)
				{
					var CurCell:Cell = m_MapData[generateMountain_i][generateMountain_j];
					var dx:int = generateMountain_i - c_MapSize/2;
					var dy:int = generateMountain_j - c_MapSize/2;
					var PositivePosition = Math.abs(dx + dy + (Math.random() - 0.5) * c_MountainRandomFactor);
					var NegativePosition = Math.abs(dx - dy + (Math.random() - 0.5) * c_MountainRandomFactor);
					var RangePosition = Math.sqrt(dx*dx + dy*dy) + (Math.random() - 0.5) * c_MountainRandomFactor;
					if(PositivePosition > c_MapSize/2 || NegativePosition > c_MapSize/2 || RangePosition > c_MapSize*3/7)
					{
						m_ToRenderCells.push(CurCell);
						CurCell.makeOuter();
						CurCell.breakWall();
						CurCell.m_Durability = -((RangePosition/c_MapSize) - 0.2)*Cell.c_DurabilityMax;
						if(CurCell.m_Durability > 0 || CurCell.m_Durability < -10)
						{
							trace(CurCell.m_Durability);
						}
					}
					
					
					++generateMountain_j;
				}
				else
				{
					generateMountain_j = 0;
					++generateMountain_i;
				}
				
				return false;
			}
			else
			{
				return true;
			}
            //trace("!generateMountainTick");
		}		
		///////////////////////////////////////////////////////////////////////////////////
		private var generateArray_i:int = 0;
		private var generateArray_j:int = 0;
		private function generateArrayTick()
		{
            //trace("generateArrayTick");
			if(generateArray_i < c_MapSize)
			{
				if(generateArray_j == 0)
				{
					m_MapData[generateArray_i] = new Array(c_MapSize);
				}
				if(generateArray_j < c_MapSize)
				{
					var NewCell:Cell = new Game.Cell(generateArray_i, generateArray_j);
					m_ToRenderCells.push(NewCell);
					
					m_MapData[generateArray_i][generateArray_j] = NewCell;
					if(generateArray_i > 0)
					{
						NewCell.m_NeighborLeft = m_MapData[generateArray_i-1][generateArray_j];
						m_MapData[generateArray_i-1][generateArray_j].m_NeighborRight = NewCell;
					}
					if(generateArray_j > 0)
					{
						NewCell.m_NeighborTop = m_MapData[generateArray_i][generateArray_j-1];
						m_MapData[generateArray_i][generateArray_j-1].m_NeighborBottom = NewCell;
					}
					++generateArray_j;
				}
				else
				{
					generateArray_j = 0;
					++generateArray_i;
				}
				
				return false;
			}
			else
			{
				return true;
			}
            //trace("!generateArrayTick");
		}		
		///////////////////////////////////////////////////////////////////////////////////
		private var m_ToRenderCells:Array = new Array();
		private function renderChangedTick():Boolean
		{
			//trace(m_ToRenderCells.length);
			if(m_ToRenderCells.length > 0)
			{
				m_ToRenderCells[0].drawAtBitmapData(bitmapDataObject1);
				//m_ToRenderCells[0].drawAt(m_Drawlayer, c_CellSize * m_Scale);
				m_ToRenderCells.splice(0, 1);
				return false;
			}
			return true;
		}
		private function renderMap()
		{
            //trace("renderMap");
			/*if(m_Drawlayer)
			{
				this.removeChild(m_Drawlayer);
				// we do not free memory
				//delete(m_Drawlayer);
			}
			m_Drawlayer = new flash.display.MovieClip();
			this.addChild(m_Drawlayer);*/
			if(!m_Drawlayer)
			{
				m_Drawlayer = new flash.display.MovieClip();
				this.addChild(m_Drawlayer);
			}
			
			for(var i:int = 0; i < c_MapSize; ++i)
			{
				for(var j:int = 0; j < c_MapSize; ++j)
				{
					var CurCell = m_MapData[i][j];
					CurCell.drawAtBitmapData(bitmapDataObject1);
					//CurCell.drawAt(m_Drawlayer, c_CellSize * m_Scale);
				}
			}
            //trace("!renderMap");
		}
    }
}