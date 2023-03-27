using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WarpTrigger : MonoBehaviour
{
    [SerializeField] Vector2 warpDestination;

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            other.transform.position = new Vector3(warpDestination.x, warpDestination.y, 0f);
        }
    }
}
