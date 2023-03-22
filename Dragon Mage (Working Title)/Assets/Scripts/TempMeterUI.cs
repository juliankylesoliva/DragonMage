using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class TempMeterUI : MonoBehaviour
{
    public static UnityEvent temperChangeEvent;

    [SerializeField] Transform startMeterRef;
    [SerializeField] Transform middleMeterRef;
    [SerializeField] Transform endMeterRef;
    [SerializeField] TemperMeterSegment[] segmentRefs;

    void Awake()
    {
        temperChangeEvent = new UnityEvent();
        temperChangeEvent.AddListener(RefreshMeterUI);
    }

    public static bool isEventInstantiated { get { return temperChangeEvent != null; } }

    private void RefreshMeterUI()
    {
        GameObject tempObj = GameObject.FindWithTag("Player");
        PlayerCtrl player = tempObj.GetComponent<PlayerCtrl>();

        if (player != null && player.temper != null)
        {
            int segments = player.temper.NumSegments;
            int coldThreshold = player.temper.coldThreshold;
            int hotThreshold = player.temper.hotThreshold;
            int currentTemperLevel = player.temper.currentTemperLevel;

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
