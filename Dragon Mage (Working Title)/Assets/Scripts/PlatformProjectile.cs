using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformProjectile : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
    }

    void FixedUpdate()
    {
        Vector2 nextPosition = this.transform.position + ((Vector3.right - Vector3.up) * Time.deltaTime);
        this.transform.position = nextPosition;
    }
}
