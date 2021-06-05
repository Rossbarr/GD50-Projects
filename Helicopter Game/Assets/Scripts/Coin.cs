using UnityEngine;

public class Coin : MonoBehaviour
{
    // Update is called once per frame
    void Update()
    {
        if (transform.position.z < -40)
        {
            Destroy(gameObject);
        }
        else
        {
            transform.Translate(0, 0, -SkyscraperSpawner.speed * Time.deltaTime, Space.World);
        }

        transform.Rotate(0, 1f, 0, Space.World);
    }

    void OnTriggerEnter(Collider other)
    {
        Debug.Log("Collect coin");
        other.transform.parent.GetComponent<Helicopter>().PickupCoin();
        Destroy(gameObject);
    }
}
