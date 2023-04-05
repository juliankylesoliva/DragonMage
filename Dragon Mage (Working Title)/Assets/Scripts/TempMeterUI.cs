using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class TempMeterUI : MonoBehaviour
{
    private PlayerCtrl player;

    [SerializeField] Vector3 cameraOffset;
    [SerializeField] Transform startMeterRef;
    [SerializeField] Transform middleMeterRef;
    [SerializeField] Transform endMeterRef;
    [SerializeField] TemperMeterSegment[] segmentRefs;

    private int previousTemperLevel = -1;
    private int previousColdThreshold = -1;
    private int previousHotThreshold = -1;
    private int previousNumSegments = -1;

    void Awake()
    {
        GameObject tempObj = GameObject.FindWithTag("Player");
        if (tempObj != null) { player = tempObj.GetComponent<PlayerCtrl>(); }
    }

    void Update()
    {
        RefreshMeterUI();
    }

    void LateUpdate()
    {
        this.transform.position = (Camera.main.transform.position + cameraOffset);
    }

    private bool DidPlayerTemperChange()
    {
        return (player.temper.currentTemperLevel != previousTemperLevel || player.temper.coldThreshold != previousColdThreshold || player.temper.hotThreshold != previousHotThreshold || player.temper.NumSegments != previousNumSegments);
    }

    private void RefreshMeterUI()
    {
        if (player != null && player.temper != null && DidPlayerTemperChange())
        {
            int segments = player.temper.NumSegments;
            int coldThreshold = player.temper.coldThreshold;
            int hotThreshold = player.temper.hotThreshold;
            int currentTemperLevel = player.temper.currentTemperLevel;

            previousNumSegments = segments;
            previousColdThreshold = coldThreshold;
            previousHotThreshold = hotThreshold;
            previousTemperLevel = currentTemperLevel;

            previousTemperLevel = currentTemperLevel;

            middleMeterRef.localScale = new Vector3((float)segments, 1f, 1f);
            endMeterRef.localPosition = (startMeterRef.localPosition + (Vector3.right * (segments / 2f)));

            for (int i = 0; i < segmentRefs.Length; ++i)
            {
                TemperMeterSegment currentSegment = segmentRefs[i];
                if (currentSegment != null)
                {
                    int segmentLevel = (i + 1);

                    if (segmentLevel > segments)
                    {
                        currentSegment.gameObject.SetActive(false);
                    }
                    else
                    {
                        currentSegment.gameObject.SetActive(true);
                        if (segmentLevel <= coldThreshold)
                        {
                            currentSegment.SetSegmentTemperature(SegmentTemperature.COLD);
                        }
                        else if (segmentLevel >= hotThreshold)
                        {
                            currentSegment.SetSegmentTemperature(SegmentTemperature.HOT);
                        }
                        else
                        {
                            currentSegment.SetSegmentTemperature(SegmentTemperature.NEUTRAL);
                        }

                        if (segmentLevel < currentTemperLevel)
                        {
                            currentSegment.SetSegmentState(SegmentState.ACTIVE);
                        }
                        else if (segmentLevel > currentTemperLevel)
                        {
                            currentSegment.SetSegmentState(SegmentState.INACTIVE);
                        }
                        else
                        {
                            currentSegment.SetSegmentState(SegmentState.FLASHING);
                        }
                    }
                }
            }
        }
    }
}
