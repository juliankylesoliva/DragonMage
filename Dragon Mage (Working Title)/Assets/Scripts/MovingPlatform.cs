using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingPlatform : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;

    /* EDITOR VARIABLES */
    [SerializeField] float moveSpeed = 1f;

    void Start()
    {
        
    }

    void Update()
    {
        if (moveSpeed != 0f)
        {
            Vector3 nextPosition = this.transform.position;
            nextPosition += (Vector3.right * moveSpeed * Time.deltaTime);
            this.transform.position = nextPosition;
        }
    }

    public void SetupDirection(bool isGoingRight = true)
    {
        moveSpeed = Mathf.Abs(moveSpeed) * (isGoingRight ? 1f : -1f);
    }

    void OnCollisionEnter2D(Collision2D col)
    {
        PlayerCtrl player = col.gameObject.GetComponent<PlayerCtrl>();
        if (player != null && player.IsGrounded)
        {
            col.transform.parent = this.transform;
        }
    }

    void OnCollisionExit2D(Collision2D col)
    {
        PlayerCtrl player = col.gameObject.GetComponent<PlayerCtrl>();
        if (player != null)
        {
            col.transform.parent = null;
        }
    }

    void OnDestroy()
    {
        foreach (Transform child in this.transform)
        {
            if (child.tag == "Player")
            {
                child.parent = null;
            }
        }
    }
}
