using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Level : MonoBehaviour
{
    [SerializeField] GameObject playerReference;
    [SerializeField] Room startingRoom;
    [SerializeField] int startingRoomEntranceIndex = 0;
    [SerializeField] Room[] roomList;

    void Start()
    {
        LevelStartup();
    }

    private void LevelStartup()
    {
        Vector2 destinationCoords = startingRoom.GetRoomEntranceCoordinates(startingRoomEntranceIndex);
        playerReference.transform.position = new Vector3(destinationCoords.x, destinationCoords.y, 0f);

        startingRoom.ActivateRoom();
        foreach (Room r in roomList)
        {
            if (r != startingRoom) { r.DeactivateRoom(); }
        }
    }
}
