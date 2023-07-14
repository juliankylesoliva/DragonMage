using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClearTimer : MonoBehaviour
{
    public static float currentTime { get; private set; }

    private bool isTimerStopped = false;

    void Start()
    {
        currentTime = 0f;
    }

    void Update()
    {
        if (!PauseHandler.isPaused && !isTimerStopped)
        {
            currentTime += Time.deltaTime;
        }
    }

    public void StopTimer()
    {
        isTimerStopped = true;
    }
}
