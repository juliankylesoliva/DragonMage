using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WarpTrigger : MonoBehaviour
{
    [SerializeField] Room roomOrigin;
    [SerializeField] Room roomDestination;
    [SerializeField] int roomEntranceIndex = 0;

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player" && roomDestination != null)
        {
            Vector2 destinationCoords = roomDestination.GetRoomEntranceCoordinates(roomEntranceIndex);
            roomDestination.ActivateRoom();
            other.transform.position = new Vector3(destinationCoords.x, destinationCoords.y, 0f);
            roomOrigin.DeactivateRoom();
        }
    }
}
