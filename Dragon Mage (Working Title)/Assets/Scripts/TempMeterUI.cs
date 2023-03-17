using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TempMeterUI : MonoBehaviour
{
    [SerializeField, Range(3, 12)] int numSegments = 12;
    [SerializeField] int coldThreshold = 3;
    [SerializeField] int hotThreshold = 10;

    private int currentTemperLevel = 6;

    public void SetTemperMeterParams(int segments, int cold, int hot, int initLevel)
    {
        if (segments < 3 || segments > 12) { return; }
        numSegments = segments;

        int maxExtreme = (segments / 2);
        if (cold > maxExtreme) { return; }
        coldThreshold = cold;
        if (hot > maxExtreme || (cold == maxExtreme && hot == maxExtreme)) { return; }
        hotThreshold = hot;

        currentTemperLevel = (1 + (numSegments / 2));
    }

    public void RefreshMeterUI()
    {

    }
}
