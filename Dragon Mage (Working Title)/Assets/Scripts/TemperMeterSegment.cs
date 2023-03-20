using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum SegmentTemperature { COLD, NEUTRAL, HOT }
public enum SegmentState { INACTIVE, ACTIVE, FLASHING }

public class TemperMeterSegment : MonoBehaviour
{
    SpriteRenderer segmentSprite;
    Animator segmentAnimator;

    [SerializeField] Color coldColor;
    [SerializeField] Color neutralColor;
    [SerializeField] Color hotColor;

    void Awake()
    {
        segmentSprite = this.gameObject.GetComponent<SpriteRenderer>();
        segmentAnimator = this.gameObject.GetComponent<Animator>();
    }

    public void SetSegmentTemperature(SegmentTemperature temper)
    {
        switch (temper)
        {
            case SegmentTemperature.COLD:
                segmentSprite.color = coldColor;
                break;
            case SegmentTemperature.HOT:
                segmentSprite.color = hotColor;
                break;
            default:
                segmentSprite.color = neutralColor;
                break;
        }
    }

    public void SetSegmentState(SegmentState state)
    {
        switch (state)
        {
            case SegmentState.FLASHING:
                segmentAnimator.Play("ActiveSegmentFlashing");
                break;
            case SegmentState.ACTIVE:
                segmentAnimator.Play("ActiveSegment");
                break;
            default:
                segmentAnimator.Play("InactiveSegment");
                break;
        }
    }
}
