using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingPlatform : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;

    /* EDITOR VARIABLES */
    [SerializeField] float moveSpeed = 1f;
    [SerializeField] float displacement = 2.5f;
    [SerializeField] float lifetime = 5f;

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

        if (lifetime > 0f)
        {
            lifetime -= Time.deltaTime;
        }
        else
        {
            GameObject.Destroy(this.gameObject);
        }
    }

    public void SetupDirection(bool isGoingRight = true, bool isDownPressed = false)
    {
        moveSpeed = Mathf.Abs(moveSpeed) * (isGoingRight ? 1f : -1f);
        this.transform.position += (Vector3.right * displacement * (isGoingRight ? 1f : -1f));
        moveSpeed *= (isDownPressed ? 0f : 1f);
    }

    void OnCollisionEnter2D(Collision2D col)
    {
        if (col.transform.tag == "Ground")
        {
            GameObject.Destroy(this.gameObject);
        }
        else if (col.transform.tag == "Player")
        {
            PlayerCtrl player = col.gameObject.GetComponent<PlayerCtrl>();
            if (player != null && player.transform.parent == null && player.IsOnMovingPlatform)
            {
                col.transform.parent = this.transform;
            }
        }
        else { /* Nothing */ }
    }

    void OnCollisionStay2D(Collision2D col)
    {
        if (col.transform.tag == "Player")
        {
            PlayerCtrl player = col.gameObject.GetComponent<PlayerCtrl>();
            if (player != null && player.transform.parent == null && player.IsOnMovingPlatform)
            {
                col.transform.parent = this.transform;
            }
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
