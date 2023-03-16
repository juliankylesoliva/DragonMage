using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyAfterTimer : MonoBehaviour
{
    [SerializeField] float expireTime = 0.5f;

    private float currentTimer = 0f;

    void Start()
    {
        currentTimer = expireTime;
    }

    void Update()
    {
        if (currentTimer > 0f)
        {
            currentTimer -= Time.deltaTime;
            if (currentTimer <= 0f)
            {
                GameObject.Destroy(this.gameObject);
            }
        }
    }
}
