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
		private static var c_MapSize:int = 500;//90000
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
			
			
			bitmapImage.height = 900;//stage.stageHeight;
			bitmapImage.width = 900;//stage.stageWidth;
			//generateMountain();
			//createCave();
			//checkReachability();
			//renderMap();
            //trace("!Map");
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
					if(meltingInitTick())
					{
						m_GenerationStep = 2;
					}
				}
				else if(m_GenerationStep == 2)
				{
					if(meltingTick())
					{
						m_GenerationStep = 3;
					}
				}
				/*else if(m_GenerationStep == 1)
				{
					if(generateMountainTick())
					{
						m_GenerationStep = 2;
					}
				}*/
				else if(m_GenerationStep == 3)
				{
					
					
					if(m_ConnectedToOuter)
					{
						if(createNextSource())
						{
							m_GenerationStep = 4;
						}
					} 
					else 
					{
						destroyTick();
					}
					//break;
				}
				else if(m_GenerationStep == 4)
				{
					if(makeInnerTick())
					{
						m_GenerationStep = 5;
					}
				}
				else if(m_GenerationStep == 5)
				{
					if(checkReachabilityTick())
					{
						m_GenerationStep = 7;
					}
				}
				else if(m_GenerationStep == 6)
				{
					if(m_RiverStable)
					{
						if(createNextWaterSource())
						{
							m_GenerationStep = 7;
						}
					}
					else
					{
						waterTick()
					}
					//break;
				}
				else if(m_GenerationStep == 7)
				{
					//waterTick();
					m_GenerationStep = 8;
				}
				else if(m_GenerationStep == 8)
				{
					return true;
				}
				++Cicles;
			}
			trace(Cicles);
			trace(checkReachabilityNeighborCells.length);
			
			//if(m_GenerationStep != 0 && m_GenerationStep != 1 && m_GenerationStep != 2)
				//renderMap();
            ////trace("!generationStep");
			return false;
		}
		//public function waterTick():
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
					if(m_MapData[m_NextSourceX][m_NextSourceY].isWall() && m_MapData[m_NextSourceX][m_NextSourceY].isInner())
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
		public function createNextWaterSource():Boolean
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
					if(m_MapData[m_NextSourceX][m_NextSourceY].isWall() && m_MapData[m_NextSourceX][m_NextSourceY].isInner())
					{
						m_WaterSources.push(m_MapData[m_NextSourceX][m_NextSourceY]);
						m_WateredCells.push(m_MapData[m_NextSourceX][m_NextSourceY]);
						return false;
					}
					//trace("!createNextSource");
				}
			}
			return true;
        }
		
		private var m_WateredCells:Array = new Array();
		private var m_WaterSources:Array = new Array();
		private var m_WaterGenerated:Boolean = false;
		private var m_Water_i:int = 0;
		private var m_RiverStable:Boolean = false;
		private var m_RiverStableTemp:Boolean = false;
		private function waterTick():Boolean
		{
			//trace(m_WaterSources.length + ", " + m_WateredCells.length + m_WaterGenerated);
			var CurCell:Cell;
			if(m_WaterGenerated)
			{
				if(m_Water_i < m_WateredCells.length)
				{
					CurCell = m_WateredCells[m_Water_i];
					var ShiftingWater:Number = CurCell.m_WaterLevel / 10;
					if(ShiftingWater > 1)
					{
						var CurNeighbor0:Cell;
						var MyLevel:Number = CurCell.getWaterCalcLevel();
						var MyGroundLevel:Number = CurCell.getGroundLevel();
						m_ToRenderCells.push(CurCell);
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
							if(CurNeighbor0)
							{
								if(!CurNeighbor0.isWall())
								{
									var NeighborLevel:Number = CurNeighbor0.getWaterCalcLevel();
									var DeltaLevel:Number = (MyLevel - NeighborLevel) / MyLevel;
									if(DeltaLevel <= 0)
									{
										continue;
									}
									
									
									if(CurNeighbor0.m_WaterLevel == 0)
									{
										m_WateredCells.push(CurNeighbor0);
									}
									
									CurNeighbor0.m_WaterLevel += ShiftingWater * DeltaLevel;
									CurCell.m_WaterLevel -= ShiftingWater * DeltaLevel;
									
									m_ToRenderCells.push(CurNeighbor0);
									
									var NeighborGroundLevel:Number = CurNeighbor0.getGroundLevel();
									var DeltaGroundLevel:Number = (MyGroundLevel - NeighborGroundLevel) / 10;
									if(DeltaGroundLevel <= 0.1)
									{
										continue;
									}
									
									CurNeighbor0.m_Durability += DeltaGroundLevel;
									CurCell.m_Durability -= DeltaGroundLevel;
									m_RiverStableTemp = false;
									
									//trace(deltaLevel + ", " + CurNeighbor0.m_WaterLevel);
								}
							}
							else
							{
								CurCell.m_WaterLevel -= ShiftingWater;
							}
						}
					}
				}
				else
				{
					m_Water_i = 0;
					m_WaterGenerated = false;
					if(m_RiverStableTemp)
					{
						m_RiverStable = true;
						return true;
					}
				}
			}
			else
			{
				if(m_Water_i < m_WaterSources.length)
				{
					CurCell = m_WaterSources[m_Water_i];
					CurCell.m_WaterLevel += 30;
					m_ToRenderCells.push(CurCell);
					//trace(CurCell.m_WaterLevel);
				}
				else
				{
					m_Water_i = 0;
					m_WaterGenerated = true;
					m_RiverStableTemp = true;
				}
			}
			++m_Water_i;
			
			return false;
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
				for(var j:int = 0; j < m_ReachableCells.length; ++j)
				{
					var CurCell:Cell = m_ReachableCells[j];
					if(CurCell.m_Durability <= 0)
					{
						if(!CurCell.isInner())
						{
							//CurCell.m_Illumination += 0.5;
							//if(CurCell.m_NeighborLeft) {CurCell.m_NeighborLeft.m_Illumination += 0.25;}
							//if(CurCell.m_NeighborRight) {CurCell.m_NeighborRight.m_Illumination += 0.25;}
							//if(CurCell.m_NeighborTop) {CurCell.m_NeighborTop.m_Illumination += 0.25;}
							//if(CurCell.m_NeighborBottom) {CurCell.m_NeighborBottom.m_Illumination += 0.25;}
							m_ConnectedToOuter = true;
							trace("connected to outer");
						}
						m_ReachableCells.splice(j, 1);
						--j;
						
					}
				}
				
				var MinDurability = Cell.c_DurabilityMax;
				var TargetCellNumber:int = -1;
				for(j = 0; j < m_ReachableCells.length; ++j)
				{
					CurCell = m_ReachableCells[j];
					if(!CurCell.isInner() && CurCell.isWall())
					{
						MinDurability = 0;
						TargetCellNumber = j;
					}
					if(MinDurability > CurCell.m_Durability )
					{
						MinDurability = CurCell.m_Durability;
						TargetCellNumber = j;
					}
				}
				
            	////trace("checking target");
				if(TargetCellNumber >= 0)
				{
            		////trace("target found");
					var TargetCell:Cell = m_ReachableCells[TargetCellNumber];
					m_ToRenderCells.push(TargetCell);
					var Damage:Number = TargetCell.m_Durability;
					var SideDamage:Number = Damage/10;
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
						if(CurNeighbor)
						{
							if(!CurNeighbor.isDamaged())
							{
								//CurNeighbor.m_WaterLevel = 1;
								m_ReachableCells.push(CurNeighbor);
								m_DamagedCells.push(CurNeighbor);
									
								//CurNeighbor.takeDamage(SideDamage, 0);
								//m_ToRenderCells.push(CurNeighbor);
							}
						}
					}
				}
				if(m_ConnectedToOuter)
				{
					for(var z:int  = 0; z < m_DamagedCells.length; ++z)
					{
						m_DamagedCells[z].makeOuter();
						m_DamagedCells[z].setDamaged(false);
						m_ToRenderCells.push(m_DamagedCells[z]);
					}
				}
			//}
			//trace("!destroyTick");
		}
		///////////////////////////////////////////////////////////////////////////////////
		private var makeInner_i:int = 0;
		private var makeInner_j:int = 0;
		private function makeInnerTick():Boolean
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
		private var meltingInit_i:int = 0;
		private var meltingInit_phase:int = 0;
		
		private var meltingRechableCells:Array = new Array();
		
		private function meltingInitTick():Boolean
		{
            //trace("!meltingInitTick " + meltingInit_i);
			var CurrentCell:Cell;
			if(meltingInit_phase == 0)
			{
				CurrentCell = m_MapData[0][meltingInit_i];
			}
			else if(meltingInit_phase == 1)
			{
				CurrentCell = m_MapData[meltingInit_i][c_MapSize - 1];
			}
			else if(meltingInit_phase == 2)
			{
				CurrentCell = m_MapData[c_MapSize - 1][c_MapSize - 1 - meltingInit_i];
			}
			else if(meltingInit_phase == 3)
			{
				CurrentCell = m_MapData[c_MapSize - 1 - meltingInit_i][0];
			}
			else
			{
				return true;
			}
			//CurrentCell.m_Illumination += 0.25;
			CurrentCell.makeOuter();
			meltingRechableCells.push(CurrentCell);
			m_ToRenderCells.push(CurrentCell);
			if(++meltingInit_i == c_MapSize)
			{
				meltingInit_phase += 1;
				meltingInit_i = 0;
			}
			//return true;
			return false;
		}
		private var melting_i:int = 0;
		private var melting_melted:int = 0;
		private function meltingTick():Boolean
		{
			if(meltingRechableCells.length > 0 && melting_melted < c_MapSize * c_MapSize * 0.1)
			{
            	//trace("!meltingTick " + meltingRechableCells.length);
				var CurrentCell:Cell = meltingRechableCells[melting_i];
				//trace("current cell: " + CurrentCell.m_X + ", " + CurrentCell.m_Y);
				if(!CurrentCell.isWall())
				{
					meltingRechableCells.splice(melting_i, 1);
					melting_i -= 1;
				}
				else if(CurrentCell.takeDirectDamage(1))
				{
					meltingRechableCells.splice(melting_i, 1);
					melting_i -= 1;
					melting_melted += 1;
					m_ToRenderCells.push(CurrentCell);
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
						if(CurNeighbor0 && CurNeighbor0.isWall())
						{
							meltingRechableCells.push(CurNeighbor0);
							//trace("added: " + CurNeighbor0.m_X + ", " + CurNeighbor0.m_Y);
						}
					}
				}
				CurrentCell.setDamaged(false);
				//checkReachabilityNeighborCells.splice(0, 1);
			
				++melting_i;
				if(melting_i >= meltingRechableCells.length)
				{
					melting_i = 0;
				}
				return false;
			}
			else
			{
				return true;
			}
		}
		private var checkReachability_init:Boolean = false;
		private var checkReachabilityNeighborCells:Array = new Array();
		private function checkReachabilityTick():Boolean
		{
            //trace("checkReachabilityTick");
			if(checkReachability_init == false)
			{
				checkReachability_init = true;
				checkReachabilityNeighborCells.push(m_MapData[0][0]);
			}
			if(checkReachabilityNeighborCells.length > 0)
			{
				var CurrentCell = checkReachabilityNeighborCells.shift();//[0];
				m_ToRenderCells.push(CurrentCell);
				if(!CurrentCell.isWall())
				{
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
						if(CurNeighbor0 && CurNeighbor0.isInner())
						{
							CurNeighbor0.makeOuter();
							checkReachabilityNeighborCells.push(CurNeighbor0);
						}
					}
				}
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
		private function generateMountainTick():Boolean
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
		private function generateArrayTick():Boolean
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