using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

public class EndOfLevelTrigger : MonoBehaviour
{
    [SerializeField] UnityEvent OnLevelEnd;

    private bool isDelayActive = false;

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            OnLevelEnd.Invoke();
        }
    }

    public void LevelCompleteSceneChange(float delay)
    {
        if (!isDelayActive)
        {
            StartCoroutine(LevelCompleteSceneChangeCR(delay));
        }
    }

    private IEnumerator LevelCompleteSceneChangeCR(float delay)
    {
        if (isDelayActive) { yield break; }

        isDelayActive = true;
        float currentTimer = 0f;
        while (currentTimer < delay)
        {
            currentTimer += Time.deltaTime;
            yield return null;
        }

        isDelayActive = false;
        SceneManager.LoadScene("LevelComplete");
    }
}
