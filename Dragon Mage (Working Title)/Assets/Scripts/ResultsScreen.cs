using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResultsScreen : MonoBehaviour
{
    private static bool isDisplayingResults = false;

    void Update()
    {

    }

    public void DisplayResults()
    {
        if (!isDisplayingResults)
        {
            StartCoroutine(DisplayResultsCR());
        }
    }

    private IEnumerator DisplayResultsCR()
    {
        if (isDisplayingResults) { yield break; }

        yield return null;
    }
}
