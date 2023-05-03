using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EndOfLevelTrigger : MonoBehaviour
{
    [SerializeField] UnityEvent OnLevelEnd;

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            OnLevelEnd.Invoke();
        }
    }
}
