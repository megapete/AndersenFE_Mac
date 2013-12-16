// Winding.cpp: implementation of the Winding class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "AndersenFE.h"
#include "Winding.h"
#include <vector>



//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Winding::Winding()
{
	m_Next = NULL;
	m_LayerHead = NULL;
	m_NumTapSteps = 0;
	m_IsRegWdg = false;
	m_IsMultiStart = false;
	m_NumLoops = 1;
	m_AxialCenterPack = 0;
	m_AxialDVGap1 = 0;
	m_AxialDVGap2 = 0;
	m_IsDoubleStack = false;
	m_Zlist = NULL;
	m_InnerRadius = 0.0;
	m_LoTap = m_HiTap = 1.0;
}

Winding::~Winding()
{
	 DeleteLayerList();

	 if (m_Zlist != NULL)
		 delete m_Zlist;

	 /*
	 CZlist* wList = m_Zlist;
	 while (wList != NULL)
	 {
		 m_Zlist = m_Zlist->m_Next;
		 delete wList;
		 wList = m_Zlist;
	 }
	 */
}

Winding* Winding::GetNext()
{
	return m_Next;
}

void Winding::SetNext(Winding *wWdg)
{
	m_Next = wWdg;
}

Layer* Winding::CompileLayerList()
{
	int i;
	Layer* result = NULL;
	Layer* lastLayer = NULL;

	CalculateRadialTurnDimn();

	double lastInnerRadius = m_InnerRadius;
	double lastRadDuctDimn = 0;
	double lastRadialBuild = 0;
	double runningNumberOfLayers = 0;
	double newNumberOfLayers = 0;
	double exactRadialTurnsPerLayer = (double)m_RadialTurns / (double)(m_NumRadialDucts + 1);


	if (IsLayerWdgWithTaps())
	{
		/*	1) Assume that if there are any ducts, at least one of them will go ABOVE the
			   layer with the reentrant gap. So, first of all, decide where the ducts will
			   go

			2) m_Zlist holds 3 elements:
				Element 1: a typical layer WITHOUT the reentrant gap
				Element 2: the lower segment of a layer WITH the reentrant gap
				Element 3: the upper segment of a layer WITH the reentrant gap

		*/

		// set up the ducts (gaps)
		// CArray<int,int> gaps;
        std::vector<int> gaps;
        
		// gaps.SetSize(29);

		double layersPerGap = (double)(m_NumLayers - 1) / (double)m_NumRadialDucts;
		double wLayer = layersPerGap;
		for (i=0; i<m_NumRadialDucts;i++)
		{
			gaps.push_back((int)floor(wLayer));
			wLayer += layersPerGap;
		}
		gaps.push_back(32); // add a dummy final value

		// force the 'middle' gap to be over the reentrant gap layer (the "tap" layer)
		if (m_NumLayers > 2)
			gaps[(int)floor((double)m_NumRadialDucts / 2.0)] = GetTapLayer();

		// define the layers that have taps on them. Note: odd-numbered layers start at
		// the bottom and finish at top (even-numbered layers are opposite)
		std::vector<int> layersWithTaps;
		// layersWithTaps.SetSize(29);
		double tapTurns, loTapTurn, turnsPerTap;
		tapTurns = m_TotalTurns * (1 - m_LoTap/m_HiTap);
		loTapTurn = GetLowTapTurn(tapTurns);
		turnsPerTap = tapTurns / m_NumTapSteps;
		double runningTurns = 0.0;

		// the next part should take into consideration the possibility of axial gaps
		// in some future revision
		
		int layerNumber = 1;
		int tapLayer = GetTapLayer();
		double turnsOnNormalLayers = m_Zlist->m_Turns;
		double turnsOnTapLayer = m_Zlist->m_Next->m_Turns * 2.0;

		while (runningTurns < (m_TotalTurns - 0.1)) // the 0.1 is for rounding errors
		{
			if (layerNumber == tapLayer)
			{
				layersWithTaps.push_back(layerNumber);
				runningTurns += turnsOnTapLayer;
			}
			else
			{
				if (((runningTurns + turnsOnNormalLayers) >= loTapTurn) &&
					(runningTurns <= (loTapTurn + tapTurns)))
				{
					layersWithTaps.push_back(layerNumber);
				}

				runningTurns += turnsOnNormalLayers;
			}

			layerNumber++;
		}

		layersWithTaps.push_back(32000); // dummy final element

		int andersenLayerNumber = 0;
		int oldLayerNumber = 0;
		int gapIndex = 0;
		int tapIndex = 0;
		CZlist* currentZlist;
		CZlist* stdZlist = m_Zlist;
		CZlist* tapZlist = m_Zlist->m_Next;
		stdZlist->m_Next = NULL;
		runningTurns = 0.0;
		double lastLayerFinishTurn = 0.0;
		double nextTapTurn = -1.0;
		double gapAddition;
		double lastOuterRadius = m_InnerRadius;
		bool changeLayer;

		Layer* nextLayer = new Layer;
		result = nextLayer;

		for (layerNumber = 1; layerNumber <= m_NumLayers; layerNumber++)
		{
			changeLayer = false;
			gapAddition = 0.0;

			if (layerNumber == tapLayer)
			{
				currentZlist = tapZlist;
			}
			else
			{
				currentZlist = stdZlist;
			}

			if (layerNumber == gaps[gapIndex])
			{
				changeLayer = true;
				gapAddition = m_RadialDuctDimn;
				gapIndex++;
				// int test = gaps[gapIndex];
			}
			if (layerNumber == layersWithTaps[tapIndex])
			{
				changeLayer = true;
				tapIndex++;
			}

			if ((layerNumber == m_NumLayers) || (layerNumber == layersWithTaps[tapIndex] - 1))
				changeLayer = true;

			runningTurns += currentZlist->GetTotalTurns();

			if (changeLayer)
			{
				andersenLayerNumber++;

				nextLayer->m_Number = andersenLayerNumber;
				nextLayer->m_CurrentDirection = m_CurrentDirection;
				nextLayer->m_InnerRadius = lastOuterRadius;
				nextLayer->m_Material = m_Material;
				nextLayer->m_NumberParGroups = m_NumberParGroups;
				nextLayer->m_NumSpacerBlocks = m_NumSpacerBlocks;
				nextLayer->m_SpacerBlockWidth = m_SpacerBlockWidth;
				nextLayer->m_Terminal = m_Terminal;
				nextLayer->m_RadialWidth = (layerNumber - oldLayerNumber) * 
											m_RadialTurnDimn * m_RadialOverBuild;

				double radialStrandsPerTurn;
				int strandsPerTurn = m_CondNumAxial * m_CondNumRadial * m_CondNumStrands;
				
				if (m_CondType == CTC_COND)
				{
					radialStrandsPerTurn = (double)m_CondNumRadial * ((m_CondNumStrands - 1) / 2);
				}
				else
				{
					radialStrandsPerTurn = (double)m_CondNumRadial * (double)m_CondNumStrands;
				}

				double numStrPerLayer = (layerNumber - oldLayerNumber) * radialStrandsPerTurn;

				if (nextTapTurn < 0)
					nextTapTurn = loTapTurn;

				
				// set up the segments
				int tapCount = CountTapsOnLayer(lastLayerFinishTurn,
					runningTurns, loTapTurn, loTapTurn + m_NumTapSteps * turnsPerTap,
					turnsPerTap);


				double segmentStartTurn = lastLayerFinishTurn;
				Segment* newPtr;
				Segment* lastPtr = NULL;
				double minZ = currentZlist->m_Zmin;

				for (i=0; i<=tapCount; i++)
				{
					newPtr = new Segment;

					if (lastPtr == NULL)
					{
						nextLayer->m_SegmentHead = newPtr;
					}
					else
					{
						lastPtr->m_Next = newPtr;
					}

					double segmentEndTurn;
					if (i == tapCount)
						segmentEndTurn = runningTurns;
					else
					{
						segmentEndTurn = nextTapTurn;
						nextTapTurn += turnsPerTap;
					}

					double layerHt = currentZlist->m_Zmax - currentZlist->m_Zmin;
					
					newPtr->m_MinZ = minZ;
					double totalLayerTurns = currentZlist->m_Turns * (layerNumber - oldLayerNumber);
					double percentOfLayerTurns = (segmentEndTurn - segmentStartTurn) / totalLayerTurns;
					newPtr->m_MaxZ = minZ + (percentOfLayerTurns * layerHt);
					minZ = newPtr->m_MaxZ;

					newPtr->m_NumTurnsTotal = segmentEndTurn - segmentStartTurn;
					
					newPtr->m_IsTappingSegment = currentZlist->m_TapSection;
					

					newPtr->m_NumStrandsPerLayer = (int)numStrPerLayer;
					newPtr->m_NumStrandsPerTurn = strandsPerTurn;
					newPtr->m_NumTurnsActive = newPtr->m_NumTurnsTotal;
					newPtr->m_StrandA = m_StrandDimnAxial;
					newPtr->m_StrandR = m_StrandDimnRadial;

					if ((layerNumber == tapLayer) && (fabs(minZ - currentZlist->m_Zmax) < 0.001))
					{
						currentZlist = currentZlist->m_Next;
						if (currentZlist != NULL)
							minZ = currentZlist->m_Zmin;
					}

					lastPtr = newPtr;



					if (tapCount > 0)
					{
						segmentStartTurn = segmentEndTurn;
					}
				}

				

				lastOuterRadius += (nextLayer->m_RadialWidth + gapAddition);
				oldLayerNumber = layerNumber;
				lastLayerFinishTurn = runningTurns;
				if (layerNumber != m_NumLayers)
				{
					nextLayer->SetNext(new Layer);
					nextLayer = nextLayer->GetNext();
				}

			} // end if (changeLayer)

			

		} // end for (layerNumber = 1;
	
		
	}
	else
	{
		for (i=0; i<=m_NumRadialDucts; i++)
		{
			Layer* nextLayer = new Layer;

			if (i == 0)
				result = nextLayer;
			else
				lastLayer->SetNext(nextLayer);

			// Enter the data for the new layer
			nextLayer->m_CurrentDirection = m_CurrentDirection;
			nextLayer->m_InnerRadius = lastInnerRadius + lastRadialBuild + lastRadDuctDimn * m_RadialOverBuild;
			lastRadDuctDimn = m_RadialDuctDimn;
			nextLayer->m_Material = m_Material;
			nextLayer->m_NumberParGroups = m_NumberParGroups;
			nextLayer->m_NumSpacerBlocks = m_NumSpacerBlocks;
			nextLayer->m_SpacerBlockWidth = m_SpacerBlockWidth;
			nextLayer->m_Terminal = m_Terminal;

			newNumberOfLayers = (double)floor((i+1)*exactRadialTurnsPerLayer + 0.5) - runningNumberOfLayers;		
			
			nextLayer->m_RadialWidth = newNumberOfLayers * m_RadialTurnDimn * m_RadialOverBuild;

			runningNumberOfLayers += newNumberOfLayers;
			lastRadialBuild = nextLayer->m_RadialWidth;
			lastInnerRadius = nextLayer->m_InnerRadius;
			lastLayer = nextLayer;

			// set up the segment data (axial sections)

			double radialStrandsPerTurn;
			int strandsPerTurn = m_CondNumAxial * m_CondNumRadial * m_CondNumStrands;
			
			if (m_CondType == CTC_COND)
			{
				radialStrandsPerTurn = (double)m_CondNumRadial * ((m_CondNumStrands - 1) / 2);
			}
			else
			{
				radialStrandsPerTurn = (double)m_CondNumRadial * (double)m_CondNumStrands;
			}

			double numStrPerLayer = newNumberOfLayers * radialStrandsPerTurn;

			CZlist* nextZ = m_Zlist;
			Segment* newPtr;
			Segment* lastPtr = NULL;

			while (nextZ != NULL)
			{
				newPtr = new Segment;

				if (lastPtr == NULL)
					nextLayer->m_SegmentHead = newPtr;
				else
					lastPtr->m_Next = newPtr;

				newPtr->m_MaxZ = nextZ->m_Zmax;
				newPtr->m_MinZ = nextZ->m_Zmin;
				newPtr->m_NumTurnsTotal = nextZ->m_Turns * newNumberOfLayers / m_RadialTurns;
				newPtr->m_IsTappingSegment = nextZ->m_TapSection;
				nextZ = nextZ->m_Next;

				newPtr->m_NumStrandsPerLayer = (int)numStrPerLayer;
				newPtr->m_NumStrandsPerTurn = strandsPerTurn;
				newPtr->m_NumTurnsActive = newPtr->m_NumTurnsTotal;
				newPtr->m_StrandA = m_StrandDimnAxial;
				newPtr->m_StrandR = m_StrandDimnRadial;

				lastPtr = newPtr;
			} // end while
			
		} // end for (i=

	} // end else

	m_LayerHead = result;

	return result;
}

void Winding::CalculateRadialTurnDimn()
{
	double copperDimn;

	if (m_CondType != CTC_COND)
	{
		copperDimn = m_StrandDimnRadial * m_CondNumStrands;
	}
	else // must be CTC_COND
	{
		copperDimn = ((m_CondNumStrands + 1) / 2) * (m_StrandDimnRadial + 0.0045f);
	} 

	copperDimn *= m_CondNumRadial;
	copperDimn += m_CondCover;

	int i = m_Type % 3;

	if (i == DISKTYPE)
	{
		double turnsPerSection = ceil(m_TotalTurns / m_NumDisks / m_NumberParGroups);
		m_RadialTurns = (int)turnsPerSection;
		m_RadialTurnDimn = copperDimn;
	}
	else if (i == LAYERTYPE)
	{
		m_RadialTurns = m_NumLayers;
		m_RadialTurnDimn = copperDimn + ((m_RadialTurns - 1) / m_RadialTurns) * m_BetweenLayers;
	}
	else // must be sheet
	{
		m_RadialTurns = (int)ceil(m_TotalTurns / m_NumberParGroups);
		m_RadialTurnDimn = copperDimn + ((m_RadialTurns - 1) / m_RadialTurns) * m_BetweenLayers;
	}
}

void Winding::DeleteLayerList(Layer *wHead)
{
	Layer* nLayer = wHead;
	Layer* lLayer;

	if (nLayer == NULL)
		nLayer = m_LayerHead;


	while (nLayer != NULL)
	{
		lLayer = nLayer->GetNext();
		delete nLayer;
		nLayer = lLayer;
	}
}

CZlist* Winding::SetDefaultZlist()
/* 
   Simply split up the winding into equal axial segments, adding appropriate tap
   sections (if any), unless the m_Axial... fields are non-zero.
   The following assumptions are made for tapping sections:
   1) If the taps are in the "center" of a winding, then:
		- If the sections are in parallel, then all odd gaps have taps
		- Otherwise, taps are in the center of the center section
			
*/
{
	int i;

	CZlist* result = NULL;
	// CZlist* newPtr;
	CZlist* sectionHead = NULL;
	CZlist* lastPtr = NULL;

	CZlist* tapPtr = NULL;

	bool fromExcel = false;
	double z1[32], z2[32], zN[32]; 
	int numSegs = 0;

	if (m_AxialCenterPack + m_AxialDVGap1 + m_AxialDVGap2 > 0.0)
	{
		fromExcel = true;

		if ((m_NumberParGroups == 2) && (m_TapLocation != NO_TAPS))
		{
			// m_TotalTurns /= 2;
			m_NumDisks /= 2;
			m_NumAxialSections = 2;
			m_BetweenSections = m_AxialCenterPack;
			m_ReentrantGap = m_AxialDVGap1;
			fromExcel = false;
		}
		else
		{
			int numSect = 1;
			if (m_AxialCenterPack > 0.0)
				numSect++;
			if (m_AxialDVGap1 > 0.0)
				numSect += 2;

			if ((numSect == 2) && (m_TapLocation == NO_TAPS) && !m_IsDoubleStack)
			{
				m_NumAxialSections = 2;
				m_BetweenSections = m_AxialCenterPack;
				m_ReentrantGap = 0;
				fromExcel = false;
			}
			else if ((numSect == 3) && (m_TapLocation == NO_TAPS) &&
				     (m_AxialCenterPack == m_AxialDVGap1) && !m_IsDoubleStack)
			{
				m_NumAxialSections = 3;
				m_BetweenSections = m_AxialCenterPack;
				m_ReentrantGap = 0;
				fromExcel = false;
			}
			else if ((numSect == 3) && (m_TapLocation == NO_TAPS) &&
				     (m_AxialCenterPack != m_AxialDVGap1) && !m_IsDoubleStack)
			{
				m_NumAxialSections = 3;
				m_BetweenSections = m_AxialDVGap1;
				m_ReentrantGap = 0;
				fromExcel = false;
			}
			else if ((numSect == 2) && (m_TapLocation == CENTER_TAPS) && 
					 (!m_IsDoubleStack))
			{
				m_NumAxialSections = 1;
				m_ReentrantGap = m_AxialCenterPack;
				fromExcel = false;
			}
			else if ((numSect == 3) && (m_TapLocation == CENTER_TAPS) && 
					 (!m_IsDoubleStack))
			// distribute taps in the two gaps
			{
				m_NumAxialSections = 1;
				m_TapLocation = DISTRIBUTED_TAPS;
				m_ReentrantGap = m_AxialDVGap1;
				fromExcel = false;
			}
			else if ((numSect == 4) && (m_TapLocation == CENTER_TAPS) && 
				(!m_IsDoubleStack))
				// distribute taps in the two gaps
			{
				m_NumAxialSections = 2;
				m_ReentrantGap = m_AxialDVGap1;
				m_BetweenSections = m_AxialCenterPack;
				// fromExcel = false;
			}
			else if (((m_IsDoubleStack) && (m_TapLocation == NO_TAPS) &&
					 (m_NumberParGroups != 2)) || ((m_TapLocation == NO_TAPS) && (numSect == 4)))
			{
				m_NumAxialSections = 1;
				z1[0] = 0;
				double sectionZ = (m_ElectricalHeight - m_AxialCenterPack) / 4 - m_AxialDVGap1 / 2;
				z2[0] = sectionZ;
				z1[1] = z2[0] + m_AxialDVGap1;
				z2[1] = z1[1] + sectionZ;
				z1[2] = z2[1] + m_AxialCenterPack;
				z2[2] = z1[2] + sectionZ;
				z1[3] = z2[2] + m_AxialDVGap1;
				z2[3] = m_ElectricalHeight;
				zN[0] = m_TotalTurns / 4;
				zN[1] = m_TotalTurns / 4;
				zN[2] = m_TotalTurns / 4;
				zN[3] = m_TotalTurns / 4;
				numSegs = 4;
			}
			// else if same as last one but with m_NumberParGroups = 2
			else if ((numSect == 2) && (m_IsDoubleStack) && (m_TapLocation == NO_TAPS) &&
					 (m_NumberParGroups == 2))
			{
				m_TotalTurns *= 2;
				m_StrandDimnAxial /= 2.0;
				m_BetweenSections = m_AxialCenterPack;
				numSegs = 2;
				fromExcel = false;
			}

		}
	}

	double zPerSection = 0.0;
	double oldZPerSection = 
		(m_ElectricalHeight - 
		(m_NumAxialSections - 1) * m_BetweenSections) /
		(m_NumAxialSections);

	double zMin = 0, zMax, zTurns;

	for (i=0; i<m_NumAxialSections; i++)
	{
		// bool testType = (m_Type == DISKTYPE);

		if ((m_TapLocation == NO_TAPS) && (!fromExcel))
		{
			zPerSection = oldZPerSection;
			zMax = zMin + zPerSection;
			zTurns = m_TotalTurns / m_NumAxialSections;
			sectionHead = new CZlist(zMin, zMax, zTurns);
		}
		else if ((m_TapLocation == CENTER_TAPS) &&
				 (m_Type == LAYERTYPE) &&
				 (m_NumAxialSections == 1))
		{
			/* special case for taps embedded in a layer winding 
			   set up the default list as follows:
			   1) if there are only two layers, the first layer has no taps
			      (implies two layers, one of one segment, one of multiple tap segments)
			   2) if 1/taprange(pu) > m_NumLayers > 2, then put the taps on the middle layer 
				  which is returned by Winding::GetTapLayer()
			   3) if m_NumLayers >= 1/taprange(pu), then the re-entrant gap is put on the
			      layer returned by Winding::GetTapLayer(), and the taps are put on previous
				  and following layers as required
			   4) for now, assume that there are 4 offload taps

			   This part will only set up three CZlists. The actual creation of the
			   winding will take place in CompileLayerList()
			*/

			double OACondAxialDimn = GetOverallAxialConductorDimn();
			double effElecHt = m_ElectricalHeight - 
				(m_AxialCenterPack + m_AxialDVGap1 + m_AxialDVGap2) * 0.98;

			double turnsOnTapLayer = (effElecHt - 1.0*0.98) / OACondAxialDimn;
			double turnsOnOtherLayers = effElecHt / OACondAxialDimn;
			

			// layers without any reentrant gap
			zPerSection = oldZPerSection;
			zMax = zMin + zPerSection;
			zTurns = turnsOnOtherLayers;
			sectionHead = new CZlist(zMin, zMax, zTurns);

			// lower segment of the layer with the reentrant gap
			zMax = zMin + (zPerSection - 0.98) / 2.0;
			zTurns = turnsOnTapLayer / 2.0;
			sectionHead->m_Next = new CZlist(zMin, zMax, zTurns);

			// upper segment
			zMin = zMax + 0.98;
			zMax = zMin + (zPerSection - 0.98) / 2.0;
			sectionHead->m_Next->m_Next = new CZlist(zMin, zMax, zTurns);
			
	

		}
		else if ((m_TapLocation == DISTRIBUTED_TAPS) &&
			    (m_Type == DISKTYPE)) 
		{
			// assume three main sections

			zPerSection = oldZPerSection / 2;
			zPerSection -= m_ReentrantGap;

			m_TotalTurns /= 2;
			tapPtr = SetTapSection(zPerSection);
			CZlist* tapPtr2 = SetTapSection(zPerSection);
			m_TotalTurns *= 2;

			const int tapLocs = 3; // 4 for 1/4 and 3/4, 3 for 1/3 and 2/3

			zTurns = (m_TotalTurns / tapLocs) - tapPtr->GetTotalTurns() / 2;
			zPerSection = oldZPerSection / tapLocs - tapPtr->GetMaxZ() / 2;

			sectionHead = new CZlist(zMin, zMin + zPerSection, zTurns);
			tapPtr->OffsetZList(zMin + zPerSection);
			sectionHead->AppendZList(tapPtr);

			zMin = tapPtr->GetMaxZ();
			if (tapLocs == 4)
			{
				zPerSection *= 2;
				zTurns *= 2;
			}
			zTurns -= tapPtr->GetTotalTurns() / 2;
			zPerSection -= tapPtr->GetTotalZ() / 2;
			sectionHead->GetTail()->AppendZList(new CZlist(zMin, zMin + zPerSection, zTurns));
			tapPtr2->OffsetZList(zMin + zPerSection);
			sectionHead->GetTail()->AppendZList(tapPtr2);
			zTurns += tapPtr2->GetTotalTurns() / 2;
			zPerSection += tapPtr2->GetTotalZ() / 2;

			zMin = tapPtr2->GetMaxZ();
			if (tapLocs == 4)
			{
				zPerSection /= 2;
				zTurns /= 2;
			}
			sectionHead->GetTail()->AppendZList(new CZlist(zMin, zMin + zPerSection, zTurns));

			
		}
		else if ((m_TapLocation == CENTER_TAPS) && 
				((m_Type == DISKTYPE) || m_Type == MULTIPLE_DISKTYPE)) 
		{
			// put the taps in the center of the segment

			double oldZMin = zMin;

			zPerSection = oldZPerSection;

			zPerSection -= m_ReentrantGap; // fix the copper height

			m_TotalTurns /= m_NumAxialSections;
			tapPtr = SetTapSection(zPerSection);
			m_TotalTurns *= m_NumAxialSections;

			zPerSection -= tapPtr->GetMaxZ() ;
			zPerSection += m_ReentrantGap;

			zPerSection /= 2;
			zTurns = (m_TotalTurns / m_NumAxialSections - tapPtr->GetTotalTurns()) / 2;

			sectionHead = new CZlist(zMin, zMin + zPerSection, zTurns);

			tapPtr->OffsetZList(zMin + zPerSection);
			sectionHead->AppendZList(tapPtr);
			
			zMin = tapPtr->GetMaxZ();

			tapPtr->GetTail()->AppendZList(new CZlist(zMin, zMin + zPerSection, zTurns));
			
			zMin = oldZMin;
			zPerSection = oldZPerSection;

		}
		else
		// all the z's must have been set up above
		{
			if (numSegs > 0)
			{
				sectionHead = new CZlist(z1[0], z2[0], zN[0]);

				int i;
				for (i=1; i<numSegs; i++)
				{
					sectionHead->GetTail()->AppendZList(new CZlist(z1[i], z2[i], zN[i]));
				}
			}
		}
		

		if (lastPtr == NULL)
			result = sectionHead;
		else
			lastPtr->m_Next = sectionHead;

        if (sectionHead != NULL)
        {
            lastPtr = sectionHead->GetTail();
        }
        
		zMin = zMin + zPerSection + m_BetweenSections;
	}

	m_Zlist = result;

	return result;
}





CZlist* Winding::SetTapSection(double copperHt, double zOffset)
{
	double zNext = zOffset;
	CZlist* result = NULL;
	CZlist* newPtr;
	CZlist* lastPtr = NULL;

	double nominalTurns = (double)floor(((m_TotalTurns / m_NumberParGroups) / m_HiTap) + 0.5);
	double loTapTurns = (double)floor(nominalTurns * m_LoTap + 0.5);
	double totalTapTurns = (m_TotalTurns / m_NumberParGroups) - loTapTurns;
	double tapTurnsPerStep = totalTapTurns / m_NumTapSteps;
	double zPerStep = copperHt * ((m_HiTap - m_LoTap)/(m_HiTap)) / m_NumTapSteps;

	int numPosTapSteps = (int)(((m_TotalTurns / m_NumberParGroups) - nominalTurns) / tapTurnsPerStep);
	int numNegTapSteps = m_NumTapSteps - numPosTapSteps;
	
	double runningNegTapSteps = 0;
	int runningPosTapSteps = 0;

	int i;

	int tapSect;

	for (i=1; i<=m_NumTapSteps; i++)
	{

		if ((runningNegTapSteps < (numNegTapSteps / 2)) &&
			(runningPosTapSteps < numPosTapSteps))
			// bottom half negative step
		{
			tapSect = NEG_TAP_SEGMENT;
			runningNegTapSteps += 1.0;
		}
		else if ((runningNegTapSteps < (double)numNegTapSteps) &&
				 (runningPosTapSteps == numPosTapSteps))
				 // top half negative step
		{
			tapSect = NEG_TAP_SEGMENT;
			runningNegTapSteps += 1.0;
		}
		else // must be a positive step
		{
			tapSect = POS_TAP_SEGMENT;
			runningPosTapSteps += 1;
		}

		newPtr = new CZlist(zNext, zNext + zPerStep, tapTurnsPerStep, tapSect);
		
		if (lastPtr == NULL)
			result = newPtr;
		else
			lastPtr->m_Next = newPtr;

		zNext += zPerStep;

		if (i == m_NumTapSteps / 2)
		{
			zNext += m_ReentrantGap; 
		}


		lastPtr = newPtr;

	}



	return result;
}


void Winding::ReverseCurrent()
{
	m_CurrentDirection *= -1;

	Layer* nextLayer = m_LayerHead;

	while (nextLayer != NULL)
	{
		nextLayer->m_CurrentDirection = m_CurrentDirection;
		nextLayer = nextLayer->GetNext();
	}
}

double Winding::GetOuterDiameter()
{
	Layer* lLayer = m_LayerHead;
	Layer* nLayer = lLayer->GetNext();

	while (nLayer != NULL)
	{
		lLayer = nLayer;
		nLayer = nLayer->GetNext();
	}

	return (lLayer->m_InnerRadius + lLayer->m_RadialWidth) * 2;
}

void Winding::OffsetZ(double wOffset)
{
	Layer* nLayer = m_LayerHead;
	Segment* nSegment;

	while (nLayer != NULL)
	{
		nSegment = nLayer->m_SegmentHead;

		while (nSegment != NULL)
		{
			nSegment->m_MinZ += wOffset;
			nSegment->m_MaxZ += wOffset;

			nSegment = nSegment->m_Next;
		}
	
		nLayer = nLayer->GetNext();
	}

}

void Winding::DefineRegulatingWdg(int wNumLoops, double wAxialGap, bool wIsDouble, 
								  bool wIsMultiStart)
/* This routine assumes that the winding has been created as a standard winding with ALL
   its turns in SERIES. If there was a gap already defined between two axial sections, the
   parameter wAxialGap will take its place.

   For multi-start windings:
		Assume that the winding has wNumLoops conductors. Assume that the electrical height
		is to the CENTER of the group of wNumLoops conductors.
*/
{
	
	Layer* nLayer = m_LayerHead;
	Segment* nSegment;
	
	int nSegs = nLayer->CountSegments();

	if ((nSegs > 2) && !wIsMultiStart)
	{
		// AfxGetMainWnd()->MessageBox("Can't make a regulating winding from a winding that has more than 2 axial segments", "Maybe next version!");
	}

	m_IsRegWdg = true;
	m_IsDoubleStack = wIsDouble;
	m_IsMultiStart = wIsMultiStart;
	m_NumLoops = wNumLoops;

	if (wIsDouble)
	{
		if (nSegs == 1)
			SplitWdgAxially(2, wAxialGap);
		else if (nSegs == 2)
		{
			Layer* nnLayer = nLayer;

			while (nnLayer != NULL)
			{
				nnLayer->m_SegmentHead->AdjustGapToNextSegment(wAxialGap);
				nnLayer = nnLayer->GetNext();
			}
		}

	} // end if (wIsDouble)

	if (wIsMultiStart)
	{
		double ctcConds = 1;
		if (m_CondType == CTC_COND)
			ctcConds = 2;
		double offset = m_CondNumAxial * (m_StrandDimnAxial * ctcConds + m_CondCover * 0.8);
		m_ElectricalHeight += offset;
		m_TotalTurns = m_TotalTurns * wNumLoops;
		
		while (nLayer != NULL)
		{
			nSegment = nLayer->m_SegmentHead;
			nSegment->m_MinZ -= offset/2.0;

			while (nSegment->m_Next != NULL)
			{
				nSegment->m_NumTurnsTotal *= wNumLoops;
				if (nSegment->m_NumTurnsActive != 0.0)
					nSegment->m_NumTurnsActive = nSegment->m_NumTurnsTotal;
				nSegment = nSegment->m_Next;
			}
			nSegment->m_MaxZ += offset/2.0;
			nSegment->m_NumTurnsTotal *= wNumLoops;
			if (nSegment->m_NumTurnsActive != 0.0)
					nSegment->m_NumTurnsActive = nSegment->m_NumTurnsTotal;

			nSegment = nLayer->m_SegmentHead;
			while (nSegment != NULL)
			{
				nSegment = nSegment->SplitSegment(nSegment->m_NumTurnsTotal);
			}


			nLayer = nLayer->GetNext();
		}
	}
	else
	{
		while (nLayer != NULL)
		{
			if (wIsDouble)
				nLayer->m_NumberParGroups = 2;

			nSegment = nLayer->m_SegmentHead;

			while (nSegment != NULL)
			{
				nSegment = nSegment->SplitSegment(wNumLoops);
			}

			nLayer = nLayer->GetNext();
		}
	}
	
}



void Winding::SplitWdgAxially(int numSegs, double wGap)
// USE ONLY FOR WINDINGS WITH SINGLE AXIAL SEGMENTS!!!
{
	Layer* nLayer = m_LayerHead;
	Segment* nSegment;

	while (nLayer != NULL)
	{
		nSegment = nLayer->m_SegmentHead;

		nSegment->SplitSegment(numSegs, wGap);

		nLayer = nLayer->GetNext();
	}
}



double Winding::GetAxialHeight()
{
	double minZ = 0, maxZ = 0;

	Segment* nSegment = m_LayerHead->m_SegmentHead;
	
	minZ = nSegment->m_MinZ;

	while (nSegment->m_Next != NULL)
		nSegment = nSegment->m_Next;
	
	maxZ = nSegment->m_MaxZ;

	return (maxZ - minZ);
}

Segment* Winding::GetMateSegment(Layer *wLayer, Segment *wSegment)
{
	if ((!m_IsDoubleStack) || (wLayer == NULL) || (wSegment == NULL))
		return NULL;

	int numSegs = wLayer->CountSegments();
	Segment* nextSeg = wLayer->m_SegmentHead;
	Segment* result = NULL;
	int i, targetSegNum = 0;

	for (i=1; i<=numSegs; i++)
	{
		if (nextSeg == wSegment)
		{
			targetSegNum = numSegs - i + 1;
			break;
		}

		nextSeg = nextSeg->m_Next;
	}

	if (targetSegNum == 0)
		return NULL;

	// we need another for-loop to take care of the situation where wSegment is in
	// the upper half of the double stack
	nextSeg = wLayer->m_SegmentHead;
	for (i=1; i<=numSegs; i++)
	{
		if (i == targetSegNum)
		{
			result = nextSeg;
			break;
		}

		nextSeg = nextSeg->m_Next;
	}

	return result;
}

double Winding::GetAxialCenter()
{
	double result = 0.0;

	result = m_LayerHead->m_SegmentHead->m_MinZ;
	result += (double)(GetAxialHeight() / 2.0);

	return result;
}

void Winding::OffsetX(double wOffset, bool otherWdgs)
{
	Layer* nextLayer;
	Winding* nextWdg = this;

	while (nextWdg != NULL)
	{
		nextLayer = nextWdg->m_LayerHead;

		while (nextLayer != NULL)
		{
			nextLayer->m_InnerRadius += wOffset;
			nextLayer = nextLayer->GetNext();
		}

		if (otherWdgs)
			nextWdg = nextWdg->GetNext();
		else
			nextWdg = NULL;
	}
}

Winding::Winding(Winding *oldWdg)
{
	// set the layer data that is inherited (not sure this is necessary)
	m_CurrentDirection = oldWdg->m_CurrentDirection;
	m_InnerRadius = oldWdg->m_InnerRadius;
	m_Material = oldWdg->m_Material;
	m_Number = oldWdg->m_Number;
	m_NumberParGroups = oldWdg->m_NumberParGroups;
	m_NumSpacerBlocks = oldWdg->m_NumSpacerBlocks;
	m_RadialWidth = oldWdg->m_RadialWidth;
	m_SpacerBlockWidth = oldWdg->m_SpacerBlockWidth;
	m_Terminal = oldWdg->m_Terminal;
	m_SegmentTail = NULL; // unused anyway

	m_ActiveTurns = oldWdg->m_ActiveTurns;
	m_AxialCenterPack = oldWdg->m_AxialCenterPack;
	m_AxialDVGap1 = oldWdg->m_AxialDVGap1;
	m_AxialDVGap2 = oldWdg->m_AxialDVGap2;
	m_BetweenDisks = oldWdg->m_BetweenDisks;
	m_BetweenLayers = oldWdg->m_BetweenLayers;
	m_BetweenSections = oldWdg->m_BetweenSections;
	m_CondCover = oldWdg->m_CondCover;
	m_CondNumAxial = oldWdg->m_CondNumAxial;
	m_CondNumRadial = oldWdg->m_CondNumRadial;
	m_CondNumStrands = oldWdg->m_CondNumStrands;
	m_CondType = oldWdg->m_CondType;
	m_ElectricalHeight = oldWdg->m_ElectricalHeight;
	m_HiTap = oldWdg->m_HiTap;
	m_IsDoubleStack = oldWdg->m_IsDoubleStack;
	m_IsRegWdg = oldWdg->m_IsRegWdg;
	m_LoTap = oldWdg->m_LoTap;
	m_Name = oldWdg->m_Name;
	m_Next = NULL;
	m_NumAxialSections = oldWdg->m_NumAxialSections;
	m_NumDisks = oldWdg->m_NumDisks;
	m_NumLayers = oldWdg->m_NumLayers;
	m_NumRadialDucts = oldWdg->m_NumRadialDucts;
	m_NumRadialSupports = oldWdg->m_NumRadialSupports;
	m_NumTapSteps = oldWdg->m_NumTapSteps;
	m_RadialDuctDimn = oldWdg->m_RadialDuctDimn;
	m_RadialOverBuild = oldWdg->m_RadialOverBuild;
	m_RadialTurnDimn = oldWdg->m_RadialTurnDimn;
	m_RadialTurns = oldWdg->m_RadialTurns;
	m_ReentrantGap = oldWdg->m_ReentrantGap;
	m_StrandDimnAxial = oldWdg->m_StrandDimnAxial;
	m_StrandDimnRadial = oldWdg->m_StrandDimnRadial;
	m_TapLocation = oldWdg->m_TapLocation;
	m_TotalTurns = oldWdg->m_TotalTurns;
	m_Type = oldWdg->m_Type;
	
	m_Zlist = new CZlist(oldWdg->m_Zlist);

	// copy layers
	Layer* nextOldLayer = oldWdg->m_LayerHead;
	Layer* lastNewLayer = NULL;
	m_LayerHead = NULL;
	while (nextOldLayer != NULL)
	{
		if (m_LayerHead == NULL)
		{
			m_LayerHead = new Layer(nextOldLayer);
			lastNewLayer = m_LayerHead;
		}
		else
		{
			lastNewLayer->SetNext(new Layer(nextOldLayer));
			lastNewLayer = lastNewLayer->GetNext();
		}

		nextOldLayer = nextOldLayer->GetNext();
	}
    
    if (lastNewLayer != NULL)
    {
        lastNewLayer->SetNext(NULL);
    }


}

void Winding::SetMaximumEffectiveTurns(Winding* wdgHead)
{
	// first set the current direction in the same direction as the other
	// windings under the same terminal

	Winding* nWdg = wdgHead;

	while (nWdg != NULL)
	{
		if ((nWdg != this) && 
			(nWdg->m_LayerHead->m_Terminal == this->m_LayerHead->m_Terminal))
		{
			SetCurrentDirection(nWdg->m_LayerHead->m_CurrentDirection);
			break;
		}

		nWdg = nWdg->GetNext();
	}

	Layer* nextLayer = m_LayerHead;
	Segment* nextSeg;
	while (nextLayer != NULL)
	{
		nextSeg = nextLayer->m_SegmentHead;
		while (nextSeg != NULL)
		{
			nextSeg->m_NumTurnsActive = nextSeg->m_NumTurnsTotal;
			nextSeg = nextSeg->m_Next;
		}
		nextLayer = nextLayer->GetNext();
	}
}

void Winding::SetCurrentDirection(int wDir)
{
	Layer* nLayer = m_LayerHead;
	m_CurrentDirection = wDir;

	while (nLayer != NULL)
	{
		nLayer->m_CurrentDirection = wDir;
		nLayer = nLayer->GetNext();
	}
}



double Winding::GetActiveTurns()
{
	double result = 0.0;

	Layer* nextLayer = m_LayerHead;
	Segment* nextSeg;
	while (nextLayer != NULL)
	{
		nextSeg = nextLayer->m_SegmentHead;
		while (nextSeg != NULL)
		{
			result += nextSeg->m_NumTurnsActive;
			nextSeg = nextSeg->m_Next;
		}
		nextLayer = nextLayer->GetNext();
	}

	return result;
}

int Winding::CountRegWdgTapPositions()
{
	/* The number of tap positions equals:
			the number of segments in the first layer *
				1 if double stack
				2 if single stack
			+ 1				
	*/
	
	int result = m_LayerHead->CountSegments();

	if (!m_IsDoubleStack)
		result *= 2;

	result += 1;

	return result;

}

void Winding::ReduceRegWdgOneStep(int currPos, bool isDouble, bool buckGapInside)
{
	int numPos = CountRegWdgTapPositions();

	if (currPos == numPos)
		return;

	Segment* wSegToZero;
	Layer* nLayer = m_LayerHead;

	int counter = 0;

	while (nLayer != NULL)
	{
		if (isDouble)
		{
			if (buckGapInside)
			{
				if (currPos > int(numPos / 2))
				{
					wSegToZero = nLayer->m_SegmentHead;

					for (counter = 1; counter < (currPos - int(numPos / 2)); counter++)
					{
						wSegToZero = wSegToZero->m_Next;
					}
					
					wSegToZero->m_NumTurnsActive = wSegToZero->m_NumTurnsTotal;
					Segment* tmpSeg = GetMateSegment(nLayer, wSegToZero);
					tmpSeg->m_NumTurnsActive = tmpSeg->m_NumTurnsTotal;
				}
				else
				{
					wSegToZero = nLayer->m_SegmentHead;

					for (counter = 1; counter < (currPos + int(numPos / 2)); counter++)
					{
						wSegToZero = wSegToZero->m_Next;
					}

					wSegToZero->m_NumTurnsActive = 0.0;
					GetMateSegment(nLayer, wSegToZero)->m_NumTurnsActive = 0.0;
				}
			}
			else
			{
			}

			
			
		}
		else // not a double stack
		{
		}

		nLayer = nLayer->GetNext();
	}
}





double Winding::GetOverallAxialConductorDimn()
{
	double result = 0.0;
	double strandWidth = m_StrandDimnAxial;

	if (m_CondType == CTC_COND)
	{
		strandWidth += 0.0045;
		strandWidth *= 2.0;
	}

	result = (strandWidth + m_CondCover*0.8) * m_CondNumAxial;

	if (m_CondType == CTC_COND)
		result += (m_CondNumAxial - 1) * m_BetweenCables;

	return result;
}

int Winding::GetTapLayer()
{
	int result = (int)floor((double)m_NumLayers / 2.0) + 1;

	return result;
}

bool Winding::IsLayerWdgWithTaps()
{
	if (((m_Type % 3) == LAYERTYPE) && (m_HiTap != m_LoTap))
		return true;
	else
		return false;
}

double Winding::GetLowTapTurn(double totalTapTurns)
{
	if ((m_Type % 3) != LAYERTYPE)
		return -1.0; // error

	int tapLayer = GetTapLayer();

	double result = m_Zlist->m_Turns * (tapLayer - 1) + m_Zlist->m_Next->m_Turns
					- (totalTapTurns / 2.0);

	return result;

}

int Winding::CountTapsOnLayer(double startTurn, double finTurn, double loTapTurn, 
							  double hiTapTurn, double turnsPerTap)
{
	if ((finTurn < loTapTurn) || (startTurn > hiTapTurn))
		return 0;

	int result = 0;

	double i;

	for (i=loTapTurn; i<finTurn; i+=turnsPerTap)
	{
		if ((i > (startTurn - 0.001)) && (i < (hiTapTurn + 0.001)))
			result++;
	}

	return result;
}
