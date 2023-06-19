using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class MedalFragmentCounterUI : MonoBehaviour
{
    [SerializeField] Vector3 cameraOffset;
    [SerializeField] TMP_Text textboxRef;

    void Update()
    {
        textboxRef.text = $"<size=6>{MedalFragment.totalFragments}<size=4>/{Level.FragmentsNeededForMedal}\n<color=#5941A9>{MedalFragment.mageFragments}<color=#FFFFFF>:<color=#F09A59>{MedalFragment.dragonFragments}";
    }

    void LateUpdate()
    {
        this.transform.position = (Camera.main.transform.position + cameraOffset);
    }
}
